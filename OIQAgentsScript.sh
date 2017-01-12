#!/bin/bash

ROOT_DIR=$(dirname "$0")
AGENT_DIR="serviceAgents"

##tomcat details ############

TOMCAT_MONITOR_AGENT="tomcatagent.sh"
TOMCAT_CONF="metrics.json"
TOMCAT_LOG4="log4j.properties"
TOMCAT_AGENT="N42tomcatAgent.jar"
TOMCAT_SERV_LOG="N42Metrics.txt"
TOMCAT_THREADS="threadCount.sh"

##mysql details ##############

MYSQL_CONF="plugin.json"
MYSQL_LOG4="log4j.properties"
MYSQL_AGENT="N42mysqlAgent.jar"
MYSQL_NEWRELIC_CONF="newrelic.json"
MYSQL_METRIC_CAT="metric.category.json"

##system agent details #########

DAEMON_FILE="Agent.py"
SERVICE_FILE="monitoragent.sh"
SYS_AGENT="SystemCheck.py"
NETW_AGENT="NetworkCheck.py"

############## Logstash ################

LOGSTASH_RB="opentsdb.rb"
LOGSTASH_CONF="opsmx-oiq.conf"
LOGSTASH_PATTERNS="opsmx-patterns"

LOGSTASH_DIR=$(dirname "$0")/logstash/
PATTREN_DIR="/opt/logstash/patterns"


        echo -n "Are you sure you want to install tomcat agent  <y/N> "
        read tprompt
        if [ "$tprompt" = "y" ] || [ "$tprompt" = "Y" ] || [ "$tprompt" = "yes" ] ||[ "$tprompt" = "Yes" ];
        then

                echo ""
                echo "[---------- Please wait downloading in process-----------------]"
                echo " "
                wget -bqc -O "$TOMCAT_CONF" 'https://rawgit.com/OpsMx/service_moniter/master/tomcatAgent/config/metrics.json'
                wget -q -O "$TOMCAT_AGENT" 'https://rawgit.com/OpsMx/service_moniter/master/tomcatAgent/N42tomcatAgent.jar'
                wget -bqc -O "$TOMCAT_LOG4" 'https://rawgit.com/OpsMx/service_moniter/master/tomcatAgent/config/log4j.properties'
                wget -bqc -O "$TOMCAT_SERV_LOG" 'https://github.com/OpsMx/service_moniter/blob/master/tomcatAgent/config/N42Metrics.txt'
                wget -bqc -O "$TOMCAT_THREADS" 'https://github.com/OpsMx/service_moniter/blob/master/tomcatAgent/threadCount.sh'
                chmod +x "$TOMCAT_AGENT" "$TOMCAT_THREADS"


                ################  Creating agent directories  ########################
                echo `date` agent directories created ...
                if [ -f /$ROOT_DIR/$AGENT_DIR ];
                  then
                     rm -r $ROOT_DIR/$AGENT_DIR/
                     echo "removed old agents"

                fi
                if [ ! -e $ROOT_DIR/$AGENT_DIR ];
                  then
                    mkdir -p $ROOT_DIR/$AGENT_DIR/tomcatAgent/config
                       if [ $? -ne 0 ];
                         then
                            echo "Could not create directory : $AGENT_DIR/$ROOT_DIR"
                            exit 1
                       fi
                fi
                 echo ""
                 echo "[----------  Copying the tomcat Agent  -----------]"
                 echo ""
                  mv -v "$TOMCAT_AGENT" "$ROOT_DIR/$AGENT_DIR/tomcatAgent/"
                  mv -v "$TOMCAT_THREADS" "$ROOT_DIR/$AGENT_DIR/tomcatAgent/"
                  mv -v "$TOMCAT_CONF" "$ROOT_DIR/$AGENT_DIR/tomcatAgent/config/"
                  mv -v "$TOMCAT_LOG4" "$ROOT_DIR/$AGENT_DIR/tomcatAgent/config/"
                  mv -v "$TOMCAT_SERV_LOG" "$ROOT_DIR/$AGENT_DIR/tomcatAgent/config/"
                 echo ""

                echo "[----------  Checking tomcat server status ---------]"
                env_dir="/etc/environment"
                tomcat_pid() {
                 echo `ps aux | grep org.apache.catalina.startup.Bootstrap | grep -v grep | awk '{ print $2 }'`
                }
                TPID=$(tomcat_pid)
                if [ "$TPID" ];
                 then
                      echo "tomcat server is running"
                else
                   echo ""
                   echo "[---------- enabling jmx port -----------------]"
                   `unset CATALINA_OPTS`
                   echo 'CATALINA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"' >> $env_dir
                   echo  "export CATALINA_OPTS" >> $env_dir
                   `source $env_dir`
                    kill -9 "$TPID"
                    echo "please source the file like 'source $env_dir'"
                    echo "please start tomcat-server manaully..."
                    exit 0
                fi

                echo "tomcat agent configration"
                echo "tomcat server host(localhost)"
                read host_ip
                sed -i '0,/localhost/s//'$host_ip'/' $ROOT_DIR/$AGENT_DIR/tomcatAgent/config/$TOMCAT_CONF
                echo "tomcat server port(8080)"
                read port
                sed -i '0,/8080/s//'$port'/' $ROOT_DIR/$AGENT_DIR/tomcatAgent/config/$TOMCAT_CONF
                echo "tomcat server jmxport(1099)"
                read jmxport
                sed -i '0,/1099/s//'$jmxport'/' $ROOT_DIR/$AGENT_DIR/tomcatAgent/config/$TOMCAT_CONF
                echo ""
                cp -r "$ROOT_DIR/$AGENT_DIR/tomcatAgent/config/"  $ROOT_DIR

                echo "[----------  tomcatagent starting process  --------------------]"
                echo ""
                                JAR_DIR=$ROOT_DIR/$AGENT_DIR/tomcatAgent/
                                tomcat_thrds=$ROOT_DIR/$AGENT_DIR/tomcatAgent/$TOMCAT_THREADS
                                echo $tomcat_thrds
                                tomcatjar="java -jar $JAR_DIR$TOMCAT_AGENT"
                                TGPID=`(ps aux | grep $TOMCAT_AGENT | grep -v grep)`
                                echo "$TGPID"
                                if [ -z "$TGPID" ];then
                                           `nohup $tomcatjar > /dev/null 2>&1 &`
                                           `nohup $tomcat_thrds > /dev/null 2>&1 &`
                                            echo $!
                                            echo  "!!! tomcat agent installation succesful !"
                                            echo `date` "tomcat agent running started ..."
                                else
                                   echo "tomcat agent already running"
                                fi
        fi

        echo -n "Are you sure you want to install mysql agent  <y/N> "
        read mprompt
        if [ "$mprompt" = "y" ] || [ "$mprompt" = "Y" ] || [ "$mprompt" = "yes" ] ||[ "$mprompt" = "Yes" ];
           then
                echo ""
                wget -bqc -O "$MYSQL_CONF" 'https://rawgit.com/OpsMx/service_moniter/master/mysqlAgent/config/plugin.json'
                wget -q -O "$MYSQL_AGENT" 'https://rawgit.com/OpsMx/service_moniter/master/mysqlAgent/N42mysqlAgent.jar'
                wget -bqc -O "$MYSQL_LOG4" 'https://rawgit.com/OpsMx/service_moniter/master/mysqlAgent/config/log4j.properties'
                wget -bqc -O "$MYSQL_NEWRELIC_CONF" 'https://rawgit.com/OpsMx/service_moniter/master/mysqlAgent/config/newrelic.json'
                wget -bqc -O "$MYSQL_METRIC_CAT" 'https://rawgit.com/OpsMx/service_moniter/master/mysqlAgent/config/metric.category.json'
                chmod +x "$MYSQL_AGENT"
                echo ""

                if [ ! -e $ROOT_DIR/$AGENT_DIR ];
                  then
                    mkdir -p $ROOT_DIR/$AGENT_DIR/mysqlAgent/config
                       if [ $? -ne 0 ];
                         then
                            echo "Could not create directory : $AGENT_DIR/$ROOT_DIR"
                            exit 1
                       fi
                  fi
               echo ""
               echo "[----------  Copying the mysql agent  -----------]"
               echo ""
                mv -v "$MYSQL_AGENT" "$ROOT_DIR/$AGENT_DIR/mysqlAgent/"
                mv -v "$MYSQL_CONF" "$ROOT_DIR/$AGENT_DIR/mysqlAgent/config/"
                mv -v "$MYSQL_NEWRELIC_CONF" "$ROOT_DIR/$AGENT_DIR/mysqlAgent/config/"
                mv -v "$MYSQL_METRIC_CAT" "$ROOT_DIR/$AGENT_DIR/mysqlAgent/config/"
                echo ""

                echo "mysql agent configration"
                echo "mysql server host(localhost)"
                read mhost_ip
                sed -i '0,/localhost/s//'$mhost_ip'/' $ROOT_DIR/$AGENT_DIR/mysqlAgent/config/$MYSQL_CONF
                echo "myql server port(3306)"
                read mport
                sed -i '0,/3306/s//'$mport'/' $ROOT_DIR/$AGENT_DIR/mysqlAgent/config/$MYSQL_CONF
                echo "myql server user(root)"
                read user
                sed -i '0,/root/s//'$user'/' $ROOT_DIR/$AGENT_DIR/mysqlAgent/config/$MYSQL_CONF
                echo "myql server password"
                read pwd
                sed -i '0,/king/s//'$pwd'/' $ROOT_DIR/$AGENT_DIR/mysqlAgent/config/$MYSQL_CONF
                cp -r "$ROOT_DIR/$AGENT_DIR/mysqlAgent/config/"  $ROOT_DIR
                echo ""
                echo "[----------  Mysqlagent starting process  --------------------]"
                echo ""
                                JAR_DIR=$ROOT_DIR/$AGENT_DIR/mysqlAgent/
                                mysqljar="java -jar $JAR_DIR$MYSQL_AGENT"
                                MPID=`(ps aux | grep $MYSQL_AGENT | grep -v grep)`
                                if [ -z "$MPID" ];then
                                         `nohup $mysqljar > /dev/null 2>&1 &`
                                          echo $!
                                          echo  "!!! MYSQL agent installation succesful !"
                                          echo `date` "MYSQL agent running started"
                                else
                                   echo "MySQL agent already running"
                                fi

        fi

        echo -n "Are you sure you want to install machine agent  <y/N> "
        read sprompt
        if [ "$sprompt" = "y" ] || [ "$sprompt" = "Y" ] || [ "$sprompt" = "yes" ] ||[ "$sprompt" = "Yes" ];
           then
                wget -bqc -O "$DAEMON_FILE" 'https://rawgit.com/OpsMx/service_moniter/master/machineAgents/Agent.py'
                wget -q -O "$SYS_AGENT" 'https://rawgit.com/OpsMx/service_moniter/master/machineAgents/SystemCheck.py'
                wget -bqc -O "$NETW_AGENT" 'https://rawgit.com/OpsMx/service_moniter/master/machineAgents/SystemCheck.py'
                wget -q -O "$SERVICE_FILE" 'https://rawgit.com/OpsMx/service_moniter/master/machineAgents/monitoragent.sh'
                chmod +x "$SERVICE_FILE" "$SYS_AGENT" "$NETW_AGENT" "$SERVICE_FILE" "$DAEMON_FILE"

                NAME="monitoragent"
                SYSAGENT_DIR="/opt/agents/monitor"
                echo ""
                if [ ! -w /etc/init.d ]; then
                  echo ""
                  echo "   mv \"$SERVICE_FILE\" \"/etc/init.d/$NAME\""
                  echo "   touch \"/var/log/$NAME.log\" && chown \"$USERNAME\" \"/var/log/$NAME.log\""
                  echo "   update-rc.d \"$NAME\" defaults"
                  echo "   service \"$NAME\" start"
                else
                  echo "[------------Agent Cleanup Started -----------]"
                  if service --status-all | grep -Fq 'monitoragent';
                  then
                       service monitoragent stop
                       echo "Please type yes as the answer as we are removing old Agents"
                       service monitoragent uninstall
                  fi
                  if [ -f $SYSAGENT_DIR/$SYS_AGENT ];
                  then
                      rm -r $SYSAGENT_DIR/
                      rm /etc/init.d/monitoragent
                  fi
                  echo ""
                  if [ ! -e $SYSAGENT_DIR/ ];
                  then
                       mkdir -p $SYSAGENT_DIR/
                       if [ $? -ne 0 ];
                       then
                            echo "Could not create directory : $SYSAGENT_DIR/"
                            exit 1
                       fi
                  fi
                  echo "[------------Copying the Agents Started -----------]"
                  mv -v "$DAEMON_FILE" "$SYSAGENT_DIR/"
                  mv -v "$SYS_AGENT" "$SYSAGENT_DIR/"
                  mv -v "$NETW_AGENT" "$SYSAGENT_DIR/"
                  mv -v "$SERVICE_FILE" "/etc/init.d/$NAME"
                  echo "[------------Copying the Agents Ended --------------]"
                  #echo "touch \"/var/log/myloop.log\""
                  #touch "/var/log/$NAME.log" && chown "$USERNAME" "/var/log/$NAME.log"
                  #echo "3. update-rc.d \"$NAME\" defaults"
                  update-rc.d "$NAME" defaults
                  echo ""
                  #echo "service \"$NAME\" start"
                  sudo  service "$NAME" start
                  echo ""
                  echo "!!! System level agents installation succesful !"
                fi
                echo ""
                echo "[--------------Agent usage Instructions------------------]"
                echo "To start the agent : service monitoragent start"
                echo "To stop the agent : service monitoragent stop"
                echo "To uninstall the agent : service monitoragent uninstall"
                echo "[--------------------------------------------------------]"
        fi

        echo -n "Are you sure you want to install logstash  <y/N> "
        read prompt
        if [ "$prompt" = "y" ] || [ "$prompt" = "Y" ] || [ "$prompt" = "yes" ] ||[ "$prompt" = "Yes" ];
         then
                LOGSTASH_PID=`ps aux | grep -v "grep" | grep "logstash" | awk 'NR==1{print $2}' | cut -d' ' -f1`
                if [ "$LOGSTASH_PID" ] > /dev/null
                then
                        echo -n `date` "logstash agent is already running"
                        sudo service logstash stop
                        echo -n `date` "stopping logstash"
                else
                        dpkg --get-selections | grep -v deinstall | grep -v forwarder | grep -w logstash > /dev/null
                        if [ $? != 0 ];
                        then
                                 echo ""
                                 echo "`date` logstash agent not found !"
                                 echo "please wait installing in progress ..."
                                 echo 'deb http://packages.elastic.co/logstash/2.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
                                 sudo apt-get -y update
                                 sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D27D666CD88E42B4
                                 sudo apt-get -y update
                                 sudo apt-get install -y logstash
                                . /etc/profile; . ~/.profile;
                                JAVA_PATH=`which java`
                                echo java path is $JAVA_PATH
                                sed '/# Override Java location/!b;n;cJAVACMD='$JAVA_PATH'' /etc/default/logstash | sudo tee /etc/default/logstash > /dev/null
                                sed '/export PATH HOME/!b;n;c\ \ export JAVACMD' /etc/init.d/logstash | sudo tee /etc/init.d/logstash > /dev/null

                        fi
                  fi
                wget -bqcO "$LOGSTASH_RB" 'https://rawgit.com/OpsMx/service_moniter/master/logstash/opentsdb.rb'
                wget -qO "$LOGSTASH_CONF" 'https://rawgit.com/OpsMx/service_moniter/master/logstash/opsmx-oiq.conf'
                wget -bqcO "$LOGSTASH_PATTERNS" 'https://rawgit.com/OpsMx/service_moniter/master/logstash/opsmx-patterns'

                if [ ! -e $LOGSTASH_DIR ];
                then
                    mkdir -p $LOGSTASH_DIR
                    mkdir -p $PATTREN_DIR
                  if [ $? -ne 0 ];
                        then
                        echo "could not create directory : $LOGSTASH_DIR"
                        exit 1
                  fi
                fi
                echo "configuring logstash .."
                mv -v "$LOGSTASH_RB" "$LOGSTASH_DIR$LOGSTASH_RB"
                mv -v "$LOGSTASH_CONF" "$LOGSTASH_DIR$LOGSTASH_CONF"
                mv -v "$LOGSTASH_PATTERNS" "$LOGSTASH_DIR$LOGSTASH_PATTERNS"
                sudo cp $LOGSTASH_DIR$LOGSTASH_CONF  "/etc/logstash/conf.d/"$LOGSTASH_CONF
                sudo mv $LOGSTASH_DIR$LOGSTASH_PATTERNS  $PATTREN_DIR/$LOGSTASH_PATTERNS
                sudo cp $LOGSTASH_DIR$LOGSTASH_RB "/opt/logstash/vendor/bundle/jruby/1.9/gems/logstash-output-opentsdb-2.0.4/lib/logstash/outputs/"$LOGSTASH_RB
                sudo service logstash start
                if [ $? -ne 0 ];
                 then
                  echo  "logstash not started properly..."
                else
                  echo "!! logstash installation succesful !"
                fi

    fi
echo ""
echo "@@@@@@@@@@@@ Thanks for installing opsmx-agents @@@@@@@@@@@@@@@@@@"
echo ""
:
