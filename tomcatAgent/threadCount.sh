#!/bin/bash
product=`cat /opt/oiq/product/home/conf/version.properties | head -2 | tail -1 | cut -d '=' -f2`
tsdb=52.8.104.253
tsdbport=4343
hostname=`hostname`
#now=$(($(date +%s%N)/1000000000))

metric1='currentThreadsStarted'
metric2='currentThreadsQueued'

if [ "$product" == "ddiq" ]; then

svalue=`curl -u oiqadmin:admin4oiq -H "Content-Type:application/json" https://localhost.outsideiq.com/ddiq-services/rest/company/progress | cut -d':' -f2 | cut -d',' -f1`

while [ $svalue -ge 0 ]
do

now=`date +%s`
svalue=`curl -u oiqadmin:admin4oiq -H "Content-Type:application/json" https://localhost.outsideiq.com/ddiq-services/rest/company/progress | cut -d':' -f2 | cut -d',' -f1`
qvalue=`curl -u oiqadmin:admin4oiq -H "Content-Type:application/json" https://localhost.outsideiq.com/ddiq-services/rest/company/progress | cut -d':' -f3 | cut -d',' -f1`
#echo "tomcat.$metric $now $mvalue host=$hostname" >> out.log
echo "put tomcat.$metric1 $now $svalue host=$hostname" | nc -w 30 $tsdb $tsdbport
echo "put tomcat.$metric2 $now $qvalue host=$hostname" | nc -w 30 $tsdb $tsdbport

done

else

svalue=`curl -u oiqadmin:admin4oiq -H "Content-Type:application/json" https://localhost.outsideiq.com/insure-services/rest/company/progress | cut -d':' -f2 | cut -d',' -f1`

while [ $svalue -ge 0 ]
do

now=`date +%s`
svalue=`curl -u oiqadmin:admin4oiq -H "Content-Type:application/json" https://localhost.outsideiq.com/insure-services/rest/company/progress | cut -d':' -f2 | cut -d',' -f1`
qvalue=`curl -u oiqadmin:admin4oiq -H "Content-Type:application/json" https://localhost.outsideiq.com/insure-services/rest/company/progress | cut -d':' -f3 | cut -d',' -f1`
#echo "tomcat.$metric $now $mvalue host=$hostname" >> out.log
echo "put tomcat.$metric1 $now $svalue host=$hostname" | nc -w 30 $tsdb $tsdbport
echo "put tomcat.$metric2 $now $qvalue host=$hostname" | nc -w 30 $tsdb $tsdbport

done

fi

