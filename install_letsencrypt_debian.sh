#!/usr/bin/env bash
# Author: Alexandre Vasconcelos
# Bash:  version 5.1.4(1)-release (x86_64-pc-linux-gnu)
# O.S: Debian 10.2.1-6
# Version: 1.0
# Description: Install Lets Encrypt with Apache and creat script for update.
# Usage: $ chmod +x install_letsencrypt_debian.sh and $ ./install_letsencrypt_debian.sh


apt-get update && \

sudo apt-get Install certbot && \

sudo apt-get install python3-certbot-apache && \

echo " Installed with success"

echo " Inform your domain with www:"
read DOMAIN1

echo " Inform your domain without www:"
read DOMAIN2

sudo certbot --apache -d $DOMAIN1 -d $DOMAIN2

echo " Do test and create one scritp for update automatically the certificate (SSL),
used the comand certbot renew --dry-run"
