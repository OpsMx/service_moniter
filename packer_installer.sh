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

echo "*********Downloading Data Dog scripts*********"
sudo apt-get update
sudo apt-get install apt-transport-https
sudo sh -c "echo 'deb https://apt.datadoghq.com/ stable main' > /etc/apt/sources.list.d/datadog.list"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7A7DA52 -y
sudo apt-get update
sudo apt-get install datadog-agent -y
sudo sh -c "sed 's/api_key:.*/api_key: 584378ca8b6271fd813591f7e75ec784/' /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf"
sudo /etc/init.d/datadog-agent start
# Enabling Apache agent
sudo mv /etc/dd-agent/conf.d/apache.yaml /etc/dd-agent/conf.d/apache_backup.yaml
sudo wget -O /etc/dd-agent/conf.d/apache.yaml https://raw.githubusercontent.com/OpsMx/service_moniter/master/apache.yaml
sudo /etc/init.d/datadog-agent info
sudo /etc/init.d/datadog-agent restart

echo "****** multiservice war deployment*******"
sudo dpkg -i monitoring-services_2.0-1_all.deb
sudo /root/apache-tomcat-7.0.75/bin/shutdown.sh
sudo /root/apache-tomcat-7.0.75/bin/startup.sh
echo "apache-tomcat restarted"

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



