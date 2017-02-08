#!/bin/bash
    #
    # watchdog
    #
    # Run as a cron job to keep an eye on what_to_monitor which should always
    # be running. Restart what_to_monitor and send notification as needed.
    #
    # This needs to be run as root or a user that can start system services.
    #
    # Revisions: 0.1 (20100506), 0.2 (20100507)

     NAME=org.apache.catalina.startup.Bootstrap
    START=/opt/apache-tomcat-7.0.72/bin/startup.sh
    GREP=/bin/grep
    PS=/bin/ps
    NOP=/bin/true
    DATE=/bin/date
    RM=/bin/rm
    while true:
    do
    $PS -ef|$GREP -v grep|$GREP $NAME >/dev/null 2>&1
    case "$?" in
     0)
     # It is running in this case so we do nothing.
      echo "$NAME is RUNNING OK. Relax."

     $NOP
     ;;
     1)
     echo "$NAME is NOT RUNNING. Starting $NAME"
     $START 2>&1 >/dev/null &
     NOTICE=/tmp/watchdog.txt
     echo "$NAME was not running and was started on `$DATE`" 
     ;;
    esac
    sleep 1m
    done 
