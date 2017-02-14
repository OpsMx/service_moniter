
OIQ Script Installtion

1) Download the opsmxAgents.py file 
2) Give the permissons to execute like 
   chmod +X opsmxAgents.py

3) run the file in command prompt like
     python opsmxAgents.py
  it will display the installer menu ,Enter according to your requirements
 
4) if you want start one agent like tomcat run like this 
    python installer.py start tomcat 
  Agents will ask configuration details like  host , port , username and password etc..	
 
5) if you want stop agent run like this 
    python installer.py stop tomcat 
	
6) Status of agents run like this 
    python opsmxAgents status

	
7) logstash configuations 
 After downloading the logstash.
open the /etc/logstash/conf.d/opsmx-oiq.conf file in your preferred editor 
then  replace "/root/oiq/logs/services-ddiq.log" with your log files absolute path, if there are multiple give comma separated "log1","log2"
and replace timezone with current machine timezone in format "+05:30" 


8) after saving your modifications run this command like this 

  service logstash logstash

 
 
 
 
 
 
