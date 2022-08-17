#!/usr/bin/env bash
# Author: Alexandre Vasconcelos
# Script Name:   firewalld.sh
# Bash:  version 5.1.4(1)-release (x86_64-pc-linux-gnu)
# O.S: Ubuntu 20.4
# Version: V1.0
# Description: Install Zimbra + Apache
# Usage: ./firewalld.sh 

#VARIABLES --------------------------------------------------------------- #

STATUS=`systemctl status firewalld | grep -i "running" | cut -d " " -f 4,5,6`
START=`systemctl start firewalld`
SHOW=`firewall-cmd --list-all | grep -i "services"`
RELOAD=`firewall-cmd --reload`

#CODE -------------------------------------------------------------------- #

clear
while true;do
echo " "
echo "Welcome at $0"
echo " "
echo "Choose a option below to start!
1- ensure firewalld service is installed
2- show firewalld status
3- start firewalld service
4- show available rules
5- add new rules
6- reload firewalld service
0- Exit script"
echo " "
echo -n "selected option: "
read option
case $option in
   1)
      if [ -x `command -v firewalld` ]
      then
         echo " "
         echo "Installed and latest version"
         sleep 2
         echo " "
      else
         echo "Not installed yet"
         sleep 2
         echo " "
      fi
      ;;
   2)

      echo " "
      echo "Firewalld status: $STATUS"
      ;;

   3)
      echo "Starting service..."
      sleep 2
      echo "$START"
      ;;
   4)
      echo -n "Rules available... $SHOW"
         echo " "
      ;;
   5)
      echo -n "Type a rule: "
      read rule
      if [ -z $rule ]
      then
         echo "You don't type nothing"
      else
         echo -n "Your rule: $rule"
         echo " "
         firewall-cmd --add-service=$rule --permanent
      fi
      echo
      ;;
   6)
      echo "Reloading..."
      sleep 2
      echo "$RELOAD"
      ;;
   *)
      echo "invalid option, please, try again!"
      ;;
esac
done
#END ------------------------------------------------------------------ #
