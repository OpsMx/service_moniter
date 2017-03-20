#!/bin/bash


echo "*********Downloading tcollector scripts*********"
sudo wget -O /opt/tcollector_opsmx.tar https://rawgit.com/OpsMx/service_moniter/master/tcollector_opsmx.tar
sudo tar -xvf /opt/tcollector_opsmx.tar -C /opt/
sudo wget -O /etc/init.d/tcollector https://raw.githubusercontent.com/OpsMx/service_moniter/master/tcollector

echo "*********Installing tcollector init scripts**************"
sudo chmod 755 /etc/init.d/tcollector
sudo update-rc.d tcollector defaults
#service tcollector start

echo "*********Installing old-script metrics*********"
sudo apt-get install -y python-pip python-dev build-essential
sudo pip install potsdb
sudo pip install boto
sudo wget -O /opt/agentinstall.sh https://raw.githubusercontent.com/OpsMx/server_monitor/master/agentinstall.sh && sudo bash /opt/agentinstall.sh


echo "*********Installing Logstash*********"
sudo echo 'deb http://packages.elastic.co/logstash/2.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D27D666CD88E42B4
sudo apt-get -y update
sudo apt-get install -y logstash
sudo wget -O  /etc/logstash/conf.d/logstash.conf https://raw.githubusercontent.com/OpsMx/service_moniter/master/opsmx_logstash.conf
sudo update-rc.d logstash defaults
#sudo service logstash restart
echo "********* Packer Installation Completed**********"



