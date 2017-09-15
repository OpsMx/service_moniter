#!/bin/bash

echo "*********Downloading tcollector scripts*********"
sudo wget -O /opt/tcollector_opsmx.tar https://rawgit.com/OpsMx/service_moniter/master/tcollector_opsmx.tar
sudo tar -xvf /opt/tcollector_opsmx.tar -C /opt/
sudo wget -O /etc/init.d/tcollector https://raw.githubusercontent.com/OpsMx/service_moniter/master/tcollector
sudo rm -rf /opt/tcollector_opsmx.tar

echo "*********Installing tcollector init scripts**************"
sudo chmod 755 /etc/init.d/tcollector
sudo update-rc.d tcollector defaults
#service tcollector start

echo "****** multiservice war deployment*******"
#sudo dpkg -i monitoring-services_2.0-1_all.deb
sudo /root/apache-tomcat-7.0.75/bin/shutdown.sh
sudo /root/apache-tomcat-7.0.75/bin/startup.sh
3echo "apache-tomcat restarted...."

echo "*********Downloading Data Dog scripts*********"
sudo apt-get update
sudo apt-get install apt-transport-https
sudo DD_API_KEY=82e5c84bec495b77a7d870ba40cc2777 bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"
# Enabling Apache agent
sudo wget -O /etc/dd-agent/conf.d/redisdb.yaml https://rawgit.com/OpsMx/service_moniter/master/redisdb.yaml
#sudo wget -O /etc/dd-agent/conf.d//tomcat.yaml https://rawgit.com/OpsMx/service_moniter/master/tomcat.yaml
#sudo wget -O /etc/dd-agent/conf.d/apache.yaml https://rawgit.com/OpsMx/service_moniter/master/apache.yaml
sudo /etc/init.d/datadog-agent info
sudo /etc/init.d/datadog-agent restart

#echo "*********Installing Logstash ***********"
#sudo echo 'deb http://packages.elastic.co/logstash/2.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D27D666CD88E42B4
#sudo apt-get -y update
#sudo apt-get install -y logstash
#sudo wget -O  /etc/logstash/conf.d/logstash.conf https://raw.githubusercontent.com/OpsMx/service_moniter/master/opsmx_logstash.conf
#sudo chmod o+rx -R /var/log/apache2/
#sudo update-rc.d logstash defaults
#sudo service logstash restart

echo "********* Packer Installation Completed**********"



