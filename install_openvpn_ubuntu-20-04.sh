#!/usr/bin/env bash
# Author: Alexandre Vasconcelos
# Bash:  version 5.1.4(1)-release (x86_64-pc-linux-gnu)
# O.S: Ubuntu 20.4
# Version: 1.2
# Description: Install openvpn and configuration
# Usage: $ chmod +x install_openvpn_ubuntu-20-04.sh and # ./install_openvpn_ubuntu-20-04

menu () {
    clear
    echo "######################################"
    echo "# Installation Server/Client OpenVPN #"
    echo "######################################"
    echo "# Before installation, verify the    #"
    echo "# name your network interface        #"
    echo "# Select the options?                #"
    echo "######################################"
    echo "# [ 1 ] OpenVPN Server               #"
    echo "# [ 2 ] Create user (.ovpn)          #"
    echo "######################################"
    read opcao
    case $opcao in
    1) OpenVPNServe ;;
    2) CreateUser ;;
    *) "Unknown Command" ; echo ; menu  ;;
    esac
}

OpenVPNServe(){
sudo apt-get update &&  sudo apt-get update && sudo apt-get install openvpn

sudo apt install easy-rsa

sudo su -c "wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg|apt-key add -"

echo "deb http://build.openvpn.net/debian/openvpn/release/2.5 focal main" | sudo tee -a  /etc/apt/sources.list.d/openvpn-aptrepo.list

sudo apt-get update && apt-get install openvpn

mkdir ~/easy-rsa

sudo ln -s /usr/share/easy-rsa/* ~/easy-rsa

echo "Start proccess configuration easy rsa"

cd ~/easy-rsa

./easyrsa init-pki

./easyrsa build-ca nopass

./easyrsa build-server-full vpn_server nopass

./easyrsa sign-req server vpn_server

./easyrsa gen-dh

cd ~/easy-rsa/pki/

sudo cp ca.crt /etc/openvpn/server/

sudo cp dh.pem /etc/openvpn/server/

cd ~/easy-rsa/pki/private/

openvpn --genkey tls-crypt-v2-server >> vpn_server.pem

sudo cp vpn_server.key /etc/openvpn/server/

sudo cp vpn_server.pem /etc/openvpn/server/

cd ~/easy-rsa/pki/issued/

sudo cp vpn_server.crt /etc/openvpn/server/

sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz  /etc/openvpn/server/

cd /etc/openvpn/server/

sudo gunzip server.conf.gz

sudo sed -i 's/dh2048.pem/dh.pem/g' /etc/openvpn/server/server.conf
sudo sed -i 's/server.crt/vpn_server.crt/g' /etc/openvpn/server/server.conf
sudo sed -i 's/server.key/vpn_server.key/g' /etc/openvpn/server/server.conf
sudo sed -i 's/tls-auth ta.key 0/tls-crypt-v2 vpn_server.pem/g' /etc/openvpn/server/server.conf
sudo sed -i 's/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway autolocal"/g' /etc/openvpn/server/server.conf
sudo sed -i 's/verb 3/verb 4/g' /etc/openvpn/server/server.conf
sudo sed -i 's/tls-auth/#tls-auth/g' /etc/openvpn/server/server.conf
sudo sed -i 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 208.67.222.222"/g' /etc/openvpn/server/server.conf
sudo sed -i 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 208.67.222.220"/g' /etc/openvpn/server/server.conf
sudo sed -i 's/;topology subnet/topology subnet/g' /etc/openvpn/server/server.conf

sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

sudo sysctl -p
 echo "what's name your interface?"
 read INTER
NAT=$(echo "*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/24 -o $INTER -j MASQUERADE
COMMIT")

echo "$NAT" | sudo tee -a /etc/ufw/before.rules

sudo sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw

sudo ufw allow 1194/udp

sudo ufw disable

sudo ufw enable

sudo systemctl start openvpn-server@server.service

sudo systemctl enable openvpn-server@server.service

}

CreateUser(){
echo "What's name user?"
read username
echo "Waint, please"

cd ~/easy-rsa/

./easyrsa gen-req $username nopass

./easyrsa sign-req client $username

openvpn --tls-crypt-v2 pki/private/vpn_server.pem --genkey tls-crypt-v2-client pki/private/$username.pem

mkdir -p ~/vpn_clients/$username

cp ~/easy-rsa/pki/ca.crt ~/vpn_clients/$username
cp ~/easy-rsa/pki/issued/$username.crt ~/vpn_clients/$username
cp ~/easy-rsa/pki/private/$username.key ~/vpn_clients/$username
cp ~/easy-rsa/pki/private/$username.pem ~/vpn_clients/$username

cd ~/vpn_clients/$username
cat <(echo -e 'client') \
<(echo -e 'proto udp') \
<(echo -e 'dev tun') \
<(echo -e 'remote <ip server> 1194') \
<(echo -e 'resolv-retry infinite') \
<(echo -e 'nobind') \
<(echo -e 'persist-key') \
<(echo -e 'persist-tun') \
<(echo -e 'remote-cert-tls server') \
<(echo -e 'cipher AES-256-GCM') \
<(echo -e 'user nobody') \
<(echo -e 'group nobody') \
<(echo -e 'FRIENDLY_NAME company') \
<(echo -e 'verb 4') \
<(echo -e '<ca>') \
ca.crt \
<(echo -e '</ca>\n<cert>') \
$username.crt \
<(echo -e '</cert>\n<key>') \
$username.key \
<(echo -e '</key>\n<tls-crypt-v2>') \
$username.pem \
<(echo -e '</tls-crypt-v2>') \
> $username.ovpn
clear
echo "Copy the data and save in format .ovpn"
echo "--------------------------------------"
sleep 10
cat ~/vpn_clients/$username/$username.ovpn

}


menu
