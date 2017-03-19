#!/bin/bash

echo "*********Installing packages*********"
sudo apt-get install -y python-pip python-dev build-essential
sudo pip install potsdb
sudo pip install boto

echo "*********Installing apache2*********"
sudo apt-get update
sudo apt-get install apache2 -y 
sudo service apache2 start

echo "*********Downloading tcollector Scripts*********"
sudo wget -O /opt/tcollector_opsmx.tar https://rawgit.com/OpsMx/service_moniter/master/tcollector_opsmx.tar
sudo tar -xvf /opt/tcollector_opsmx.tar -C /opt/

sudo python /opt/tcollector/tcollector.py -H 52.8.104.253 -p 4343 -D
echo "tcollector started with PID> $!"
echo ""

echo "*********Installing JDK8*********"
sudo apt-get install -y python-software-properties debconf-utils
sudo echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 select true' | debconf-set-selections
sudo echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true' | debconf-set-selections
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
sudo apt-get install -y oracle-java8-installer
java -version

echo "*********Installing Logstash*********"
sudo echo 'deb http://packages.elastic.co/logstash/2.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D27D666CD88E42B4
sudo apt-get -y update
sudo apt-get install -y logstash
sudo wget -O  /etc/logstash/conf.d/logstash.conf https://raw.githubusercontent.com/OpsMx/service_moniter/master/opsmx_logstash.conf
sudo service logstash restart

echo "*********Installing packetbeat*********"
sudo wget -O /opt/packetbeat_install.sh https://raw.githubusercontent.com/OpsMx/server_monitor/master/packetbeat_install.sh && sudo chmod 777 packetbeat_install.sh && sudo bash /opt/packetbeat_install.sh
echo
echo "*********Installing sys-metrics*********"
sudo wget -O /opt/agentinstall.sh https://raw.githubusercontent.com/OpsMx/server_monitor/master/agentinstall.sh && sudo bash /opt/agentinstall.sh
echo 

echo '#!/bin/sh -e'>/etc/rc.local
echo 'sudo service apache2 start'>>/etc/rc.local
echo 'sudo service logstash start'>>/etc/rc.local
echo 'sudo service packetbeat start'>>/etc/rc.local
echo 'sudo python /opt/tcollector/tcollector.py -H 52.8.104.253 -p 4343 -D '>>/etc/rc.local
echo 'exit 0'>>/etc/rc.local
echo "******* Copied init serivces *************************"
echo 
