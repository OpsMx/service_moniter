#!/usr/bin/env python
'''
Author: OpsMx
Description: Installs OpsMx agents in machine (Tomcat Agent, MySQL Agent, System Agent, Logstash Agent)
'''

import os
import subprocess
import re
import json
import sys
import getpass
import stat

pwd=os.path.dirname(os.path.realpath(__file__))
agents_path=os.path.join(pwd,"serviceAgents")

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class Downloader:
    def __init__(self,file_paths,machine):
        self.file_paths=file_paths
        if machine:
            for file, dir in self.file_paths.items():
                if not os.path.exists("/opt/agents/monitor/{}".format(file)):
                    try:
                        os.makedirs("/opt/agents/monitor")
                    except:
                        pass
                    print "Downloading...",file
                    os.system("wget -q -O /opt/agents/monitor/{} https://rawgit.com/OpsMx/service_moniter/master/{}/{}".format(file,dir,file))
            if not os.path.exists("/etc/init.d/monitoragent"):
                os.system("wget -q -O /etc/init.d/monitoragent https://rawgit.com/OpsMx/service_moniter/master/machineAgents/monitoragent.sh")
                os.chmod("/etc/init.d/monitoragent", 0o777)
        else:
            for file, dir in self.file_paths.items():
                desired_path=os.path.join(agents_path,dir,file)
                if not os.path.exists(desired_path):
                    try:
                        os.makedirs(os.path.join(agents_path,dir))
                    except:
                        pass
                    print "Downloading...",file
                    os.system("wget -q -O {0} https://rawgit.com/OpsMx/service_moniter/master/{1}/{2}".format(desired_path,dir,file))
                    os.chmod(desired_path, 0o777)

class TomcatAgent:
    def __init__(self):
        self.config_path={"metrics.json":"tomcatAgent/config",
                          "log4j.properties":"tomcatAgent/config",
                          "N42tomcatAgent.jar":"tomcatAgent",
                          "N42Metrics.txt":"tomcatAgent/config",
                          "threadCount.sh":"tomcatAgent"}
        Downloader(self.config_path,False)

    def configure(self):
        print bcolors.HEADER+"\n*****************Tomcat Agent Installation*****************"+bcolors.ENDC
        print bcolors.WARNING+"If JMX is running, enter existing JMX port. Otherwise, enter new JMX to set in environmental variable"+bcolors.ENDC
        while True:
            print ""
            host=raw_input("Please enter tomcat server host ip ".ljust(36," ")+bcolors.OKBLUE+"[Default:localhost]>"+bcolors.ENDC)
            if not host.strip() or host.strip()=="localhost":
                host="localhost"
            
            elif not re.search(r'^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$',host) and host.strip() :
                print bcolors.FAIL+"Invalid IP. Please try again!"+bcolors.ENDC
                continue
            
            port=raw_input("Please enter tomcat server port ".ljust(40," ")+bcolors.OKBLUE+"[Default: 8080]>"+bcolors.ENDC)
            if not port.isdigit() and port.strip():
                print bcolors.FAIL+"Invalid port number. Please try again!"+bcolors.ENDC
                continue
            elif not port.strip():
                port="8080"

            jmxport=raw_input("Please enter tomcat server jmxport ".ljust(40," ")+bcolors.OKBLUE+"[Default: 1099]>"+bcolors.ENDC)
            if not jmxport.isdigit() and jmxport.strip():
                print bcolors.FAIL+"Invalid port number. Please try again!"+bcolors.ENDC
                continue
            elif not jmxport.strip():
                jmxport="1099"

            print "Host:".ljust(12," "),":",host
            print "Port:".ljust(12," "),":",port
            print "JMX Port:".ljust(12," "),":",jmxport
            res=raw_input("Please confirm your input "+bcolors.OKBLUE+"[y/n]>"+bcolors.ENDC)
            if res.capitalize()=="Y":
                break
            else:
                continue

        try:
            tomcat_pid=subprocess.check_output("ps aux | grep -w org.apache.catalina.startup.Bootstrap | grep -v grep | awk '{ print $2 }'", shell=True)
        except:
            tomcat_pid=None
        try:
            jmx_pid=subprocess.check_output("ps aux | grep jmx | grep -v grep | awk '{ print $2 }'",shell=True)
        except:
            jmx_pid=None
        if jmx_pid is not None:
            print bcolors.WARNING+"JMX not found!"+bcolors.ENDC
            while True:
                tomcat_path=raw_input("\nPlease enter tomcat location to set environment variable in 'setenv.sh'"+ bcolors.OKBLUE+"(e.g./home/apache-x.x.x) >"+bcolors.ENDC)
                
                if tomcat_path and os.path.exists(tomcat_path):
                    setenv_path=os.path.join(tomcat_path,"bin/setenv.sh")
                    if os.path.exists(os.path.join(tomcat_path,"bin")):
                        with open(setenv_path,"a+") as f:
                            if "CATALINA_OPTS" not in f.read() and jmxport not in f.read():
                                f.write('CATALINA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port={} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"'.format(jmxport))
                        os.chmod(setenv_path, 0o777)
                        break
                    else:
                        print bcolors.FAIL+"'bin' directory not found. Please check the path"+bcolors.ENDC
                else:
                    print bcolors.FAIL+"Did you enter correct path? "+bcolors.ENDC

            res=raw_input("Environmental variable was set."+bcolors.OKBLUE+"Need to restart tomcat. Do you want to continue?[y/n]>"+bcolors.ENDC)
            if res.capitalize()=="Y":
                startup=os.path.join(tomcat_path,"bin/startup.sh")
                if os.path.exists(startup):
                    os.system("sudo kill -9 {} {}".format(tomcat_pid ,jmx_pid))
                    os.system("sh {}".format(startup))
                    print bcolors.OKGREEN+"Tomcat restared!"+bcolors.ENDC
                else:
                    print bcolors.FAIL+startup+" not found. Please restart tomcat manually"+bcolors.ENDC
            else:
                print bcolors.WARNING+"Please restart tomcat manually"+bcolors.ENDC
        #Read the JSON
        with open(os.path.join(agents_path,self.config_path["metrics.json"],"metrics.json"),'r') as f:
            config_dict=json.load(f)
        #Update the JSON
        for index,values in enumerate(config_dict["tomcat"]):
            config_dict["tomcat"][index]["host_ip"]=host
            config_dict["tomcat"][index]["port"]=port
            config_dict["tomcat"][index]["jmxport"]=jmxport
        #Write the JSON
        with open(os.path.join(agents_path,self.config_path["metrics.json"],"metrics.json"),'w') as f:
            json.dump(config_dict,f)
        self.stopAgent()
        os.system("cp -R {} {}".format("serviceAgents/tomcatAgent/config", pwd))
        self.startAgent()

    def status(self):
        try:
            agent_pid=subprocess.check_output("ps aux | grep -e N42tomcatAgent.jar | grep -v grep | awk '{print $2}'",shell=True)
        except:
            agent_pid=None
        return agent_pid

    def startAgent(self):
        if self.status():
            print bcolors.OKGREEN+"The tomcat agent is running already"+bcolors.ENDC
        else:
            os.system("sh {} >> /dev/null 2>&1 &".format(agents_path,self.config_path["threadCount.sh"],"threadCount.sh"))
            os.system("nohup java -jar  {} >> /dev/null 2>&1 &".format(os.path.join(agents_path,self.config_path["N42tomcatAgent.jar"],"N42tomcatAgent.jar")))
            print bcolors.OKGREEN+"Tomcat agent started"+bcolors.ENDC

    def stopAgent(self):
        for x in range(2):
            os.system("pkill -f {}".format("N42tomcatAgent.jar"))
        print bcolors.FAIL+"Tomcat agent killed"+bcolors.ENDC

    def restartAgent(self):
        self.stopAgent()
        self.startAgent()

class MySQLAgent:
    def __init__(self):
        self.config_path={
                          "plugin.json":"mysqlAgent/config",
                          "log4j.properties":"mysqlAgent/config",
                          "N42mysqlAgent.jar":"mysqlAgent",
                          "newrelic.json":"mysqlAgent/config",
                          "metric.category.json":"mysqlAgent/config"}
        Downloader(self.config_path,False)

    def configuration(self):
        print bcolors.HEADER+"*****************MySQL Agent Installation*****************"+bcolors.ENDC
        while True:
            print ""
            host=raw_input("Please enter MySQL server host ip ".ljust(37," ")+bcolors.OKBLUE+"[Default:localhost]>"+bcolors.ENDC)
            if not re.search(r'^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$',host) and host.strip() :
                print bcolors.FAIL+"Invalid IP. Please try again!"+bcolors.ENDC
                continue
            elif not host.strip():
                host="localhost"

            port=raw_input("Please enter MySQL server port ".ljust(40," ")+bcolors.OKBLUE+"[Default: 3306]>"+bcolors.ENDC)
            if not port.isdigit() and port.strip():
                print bcolors.FAIL+"Invalid port number. Please try again!"+bcolors.ENDC
                continue
            elif not port.strip():
                port="3306"

            username=raw_input("Please enter MySQL username ".ljust(40," ")+bcolors.OKBLUE+"[Default: root]>"+bcolors.ENDC)
            if not username:
                username="root"

            password=getpass.getpass("Please enter MySQL password".ljust(55," ")+bcolors.OKBLUE+">"+bcolors.ENDC)
            if not password.strip():
                print bcolors.FAIL+"Password should not be empty. Please try again!"+bcolors.ENDC
                continue
            print "Host".ljust(12," "),":",host
            print "Port".ljust(12," "),":",port
            print "Username".ljust(12," "),":",username
            print "Password".ljust(12," "),": ******"
            res=raw_input("Please confirm your input "+bcolors.OKBLUE+"[y/n]>"+bcolors.ENDC)
            if res.capitalize()=="Y":
                break
            else:
                continue
        #Reading File
        with open(os.path.join(agents_path,self.config_path["plugin.json"],"plugin.json"),'r') as f:
            config_dict=json.load(f)
        #Update the JSON
        for index,values in enumerate(config_dict["agents"]):
            config_dict["agents"][index]["host_ip"]=host
            config_dict["agents"][index]["port"]=port
            config_dict["agents"][index]["passwd"]=password
            config_dict["agents"][index]["user"]=username
        #Write the JSON

        with open(os.path.join(agents_path,self.config_path["plugin.json"],"plugin.json"),'w') as f:
            json.dump(config_dict,f)

        self.stopAgent()
        os.system("cp -R {} {}".format("serviceAgents/mysqlAgent/config", pwd))
        #print os.path.join(agents_path,self.config_path["N42mysqlAgent.jar"],"N42mysqlAgent.jar"),"<==Path"
        self.startAgent()

    def status(self):
        try:
            agent_pid=subprocess.check_output("ps aux | grep -e N42mysqlAgent.jar | grep -v grep | awk '{print $2}'",shell=True)
        except:
            agent_pid=None
        return agent_pid

    def startAgent(self):
        if self.status():
            print bcolors.OKGREEN+"MySQL agent is running already"+bcolors.ENDC
        else:
            return_status=os.system("nohup java -jar {} > /dev/null 2>&1 &".format(os.path.join(agents_path,self.config_path["N42mysqlAgent.jar"],"N42mysqlAgent.jar")))
            if return_status==0:
                print bcolors.OKGREEN+"MySQL agent started"+bcolors.ENDC

    def stopAgent(self):
        for x in range(2):
            os.system("pkill -f {}".format("N42mysqlAgent.jar"))
        print bcolors.FAIL+"MySQL agent killed!"+bcolors.ENDC

    def restartAgent(self):
        self.stopAgent()
        self.startAgent()

class MachineAgent:
    def __init__(self):
        self.config_path={
                          "Agent.py":"machineAgents",
                          "SystemCheck.py":"machineAgents",
                          "NetworkCheck.py":"machineAgents"}
        Downloader(self.config_path,True)
        self.agent_name="monitoragent"

    def configure(self):
        print bcolors.HEADER+"\n*****************System Agent Installation*****************"+bcolors.ENDC
        with open("/var/log/{}.log".format(self.agent_name),"w") as f:
            pass
        os.system("update-rc.d {} defaults".format(self.agent_name))
        os.system("service {} start".format(self.agent_name))

    def removeAgent(self):
        print bcolors.HEADER+"\n*****************System Agent Uninstallation*****************"+bcolors.ENDC
        os.system("service {} stop".format(self.agent_name))
        os.system("service {} uninstall".format(self.agent_name))
        os.system("rm /etc/init.d/{}".format(self.agent_name))

class LogstashAgent:
    def __init__(self):
        self.config_path={"opsmx-patterns":"/opt/logstash/patterns",
                          "opsmx-oiq.conf":"/etc/logstash/conf.d",
                          "opentsdb.rb":"/opt/logstash/vendor/bundle/jruby/1.9/gems/logstash-output-opentsdb-2.0.4/lib/logstash/outputs/"
                          }

    def downloader(self):
        for file, dir in self.config_path.items():
            desired_path=os.path.join(agents_path,dir,file)
            if not os.path.exists(desired_path):
                try:
                    os.makedirs(os.path.join(agents_path,dir))
                except:
                    pass
                print "Downloading...",file
                os.system("wget -q -O {0} https://rawgit.com/OpsMx/service_moniter/master/logstash/{1}".format(desired_path,file))
                os.chmod(os.path.join(desired_path,dir,file),0o777)


    def configure(self):
        print bcolors.HEADER+"\n*****************Logstash Installation*****************"+bcolors.ENDC
        try:
            logstash_pid=subprocess.check_output("ps aux | grep -v grep | grep logstash | awk '{print $2}'",shell=True)
        except:
            logstash_pid=None
        if logstash_pid:
            self.downloader()
            print "Logstash Installed. Restarting"
            os.system("sudo service logstash restart")
        else:
            if os.system("dpkg --get-selections | grep -v deinstall | grep -v forwarder | grep -w logstash")!=0:
                print "Logstash not found. Installing.."
                os.system("sudo rm -rf /etc/init.d/logstash")
                os.system("sudo rm -rf /etc/defalut/logstash")
                os.system("rm -rf /var/lib/logstash/")
                os.system("rm -rf /var/log/logstash/")
                os.system("rm -rf /opt/logstash/")
                with open("/etc/apt/sources.list.d/logstash.list","w") as f:
                    f.write("deb http://packages.elastic.co/logstash/2.4/debian stable main")
                os.system("sudo apt-get -y update")
                os.system("apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D27D666CD88E42B4")
                os.system("sudo apt-get -y update")
                os.system("sudo apt-get install -y logstash --allow-unauthenticated")
                os.system("service logstash stop")
            self.downloader()
            os.system("sudo service logstash restart")
        print bcolors.BOLD+bcolors.WARNING+"NOTE: Please update log files location in config file (/etc/logstash/conf.d/) and set 'chmod 664' for those log files"+bcolors.ENDC

def help():
    print bcolors.FAIL+"Invalid command line agruments"+bcolors.ENDC
    print bcolors.WARNING+"Usage: python installer.py [status] [start | stop | restart tomcat | mysql]"+bcolors.ENDC

if __name__=='__main__':
    if not os.geteuid() == 0:
        print bcolors.FAIL+"Script must run with 'sudo'"+bcolors.ENDC
        exit()
    if len(sys.argv)==3:
        if sys.argv[2]=="mysql":
            mysql=MySQLAgent()
            if sys.argv[1]=="start":
                mysql.startAgent()
            elif sys.argv[1]=="stop":
                mysql.stopAgent()
            elif sys.argv[1]=="restart":
                mysql.restartAgent()
            else:
                help()
        elif sys.argv[2]=="tomcat":
            tomcat=TomcatAgent()
            if sys.argv[1]=="start":
                tomcat.startAgent()
            elif sys.argv[1]=="stop":
                tomcat.stopAgent()
            elif sys.argv[1]=="restart":
                tomcat.restartAgent()
            else:
                help()
        else:
            help()
    elif len(sys.argv)==2:
        if sys.argv[1]=="status":
            tomcat=TomcatAgent()
            mysql=MySQLAgent()
            if tomcat.status():
                print bcolors.OKGREEN+"Tomcat Agent".ljust(15,"."),"RUNNING"+bcolors.ENDC
            else:
                print bcolors.FAIL+"Tomcat Agent".ljust(15,"."),"STOPPED"+bcolors.ENDC
            if mysql.status():
                print bcolors.OKGREEN+"MySQL Agent".ljust(15,"."),"RUNNING"+bcolors.ENDC
            else:
                print bcolors.FAIL+"MySQL Agent".ljust(15,"."),"STOPPED"+bcolors.ENDC
        else:
            help()

    else:
        print bcolors.BOLD+bcolors.HEADER+"\n*****************OpsMx Agent Installation Menu(For Ubuntu)*****************"+bcolors.ENDC
        print bcolors.OKBLUE+"NOTE1: For system agent, please use 'service monitoragent [start | stop | restart]'"+bcolors.ENDC
        print bcolors.OKBLUE+"NOTE2: To control service agents use; python installer.py [status] [start | stop | restart tomcat | mysql]"+bcolors.ENDC
        print bcolors.FAIL+"NOTE3: Please run below MySQL queries in MySQL command line to give permissions to IP to pull metrics"+bcolors.ENDC
        print bcolors.BOLD+"\nCREATE USER '<MySQL_User>'@'<MySQL_IP or localhost>' IDENTIFIED BY '<MySQL_Password>';"+bcolors.ENDC
        print bcolors.BOLD+"GRANT ALL PRIVILEGES ON * TO '<MySQL_User>'@'<MySQL_IP or localhost>' WITH GRANT OPTION;"+bcolors.ENDC
        print "\nPlease select an option to install agent(s)"
        res=raw_input("1. Tomcat Agent \n2. MySQL Agent \n3. Logstash Agent  \n4. Install System Agent \n5. Remove System Agent \n6. All (Except 'Remove System Agent') \n>")
        if res=="1":
            tomcat=TomcatAgent()
            tomcat.configure()
        elif res=="2":
            mysql=MySQLAgent()
            mysql.configuration()
        elif res=="3":
            logstash=LogstashAgent()
            logstash.configure()
        elif res=="4":
            sys=MachineAgent()
            sys.configure()
        elif res=="5":
            sys=MachineAgent()
            sys.removeAgent()
        elif res=="6":
            tomcat=TomcatAgent()
            tomcat.configure()
            mysql=MySQLAgent()
            mysql.configuration()
            sys=MachineAgent()
            sys.configure()
            logstash=LogstashAgent()
            logstash.configure()
