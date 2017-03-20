#!/bin/bash


echo "*********Downloading tcollector scripts*********"
sudo wget -O /opt/tcollector_opsmx.tar https://rawgit.com/OpsMx/service_moniter/master/tcollector_opsmx.tar
sudo tar -xvf /opt/tcollector_opsmx.tar -C /opt/
sudo wget -O /etc/init.d/tcollector https://raw.githubusercontent.com/OpsMx/service_moniter/master/tcollector

echo "*********Installing tcollector init scripts**************"
#sed -i '/SCRIPT=/c\SCRIPT="python /opt/tcollector/tcollector.py -H 52.8.104.253 -p 4343 -D"' /home/tushar/Desktop/tcollector
sudo chmod 777 /etc/init.d/tcollector
update-rc.d tcollector defaults
service tcollector start

echo "*********Installing Logstash*********"
sudo echo 'deb http://packages.elastic.co/logstash/2.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D27D666CD88E42B4
sudo apt-get -y update
sudo apt-get install -y logstash
sudo wget -O  /etc/logstash/conf.d/logstash.conf https://raw.githubusercontent.com/OpsMx/service_moniter/master/opsmx_logstash.conf
sudo service logstash restart


#echo "*********Installing packetbeat*********"
#sudo wget -O /opt/packetbeat_install.sh https://raw.githubusercontent.com/OpsMx/server_monitor/master/packetbeat_install.sh && sudo chmod 777 /opt/packetbeat_install.sh && sudo bash /opt/packetbeat_install.sh
#echo
sudo apt-get install -y python-pip python-dev build-essential
sudo pip install potsdb
sudo pip install boto
sudo wget -O /opt/agentinstall.sh https://raw.githubusercontent.com/OpsMx/server_monitor/master/agentinstall.sh && sudo bash /opt/agentinstall.sh

echo '#!/bin/sh -e'>/etc/rc.local
echo 'sudo /etc/init.d/logstash start'>>/etc/rc.local
echo 'sudo /etc/init.d/tcollector start'>>/etc/rc.local
#echo 'sudo /etc/init.d/apache2 start'>>/etc/rc.local
echo 'exit 0'>>/etc/rc.local

sudo chmod 777 /etc/rc.local
