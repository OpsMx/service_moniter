IQ- Agents 

1) Extract the .gz files

Machine-Agents:
 
       1) Open the machineAgents folder in terminal
       2) run below command on terminal (type enter for 2 times)
 
     nohup python Agent.py > machineAgents.log 2>&1

	 
Tomcat-Agent :

        1)Enabling jmx port:  
              copy the setenv.sh file to tomcat-server/bin location then restart server 
	2)open the tomcatAgent folder location in terminal
	3)open the plugin.json (under config folder) in your preferred editor to change serverport , host,ip save them.
	4)run below command on terminal (type enter for 2 times)
 	  
             nohup java -jar N42tomcatAgent.jar > /dev/null &
	     nohup threadCount.sh > /dev/null &
	
Mysql-Agent :
    
	1)open the mysqlAgent folder location in terminal
	2)open the plugin.json (under config folder) in your preferred editor to change (mysql)host,ip, username and password save them.
	3)run below command on terminal (type enter for 2 times)
	  
	    nohup java -jar N42mysqlAgent.jar > /dev/null &
		
------------------------------------------------------------------------------------------------------------------------------------------
Logstash-Agent:

#Install latest version of java - minimum Java7 required

#Logstash installation script: run below commands
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://packages.elastic.co/logstash/2.4/debian stable main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update && sudo apt-get install logstash

#open oiq-agents logstash folder: run below command
cd logstash

#Logstash configuration copy: run below command
sudo cp opsmx-oiq.conf /etc/logstash/conf.d/
#open file /etc/logstash/conf.d/opsmx-oiq.conf and 
sudo vi /etc/logstash/conf.d/opsmx-oiq.conf
#replace "/root/oiq/logs/services-ddiq.log" with your log file absolute path, if there are multiple give comma separated "log1","log2"
#replace timezone with current machine timezone in format "+05:30"

#Logstash patterns copy:
sudo mkdir /opt/logstash/patterns/
sudo cp opsmx-patterns /opt/logstash/patterns/

#Logstash opentsdb plugin change:
sudo cp opentsdb.rb /opt/logstash/vendor/bundle/jruby/1.9/gems/logstash-output-opentsdb-2.0.4/lib/logstash/outputs/opentsdb.rb
sudo service logstash start

