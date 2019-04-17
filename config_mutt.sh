#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "=================================Config Mutt================================"
echo "========================================================================="

if [ "$1" != "--help" ]; then
smtphost=""
read -p "Please input smtphost:" smtphost
if [ "$smtphost" = "" ]; then
   echo "Error: smtphost Can't be empty!!"
   exit 1
fi
smtpport=""
read -p "Please input smtpport:" smtpport
if [ "$smtpport" = "" ]; then
   echo "Error: smtpport Can't be empty!!"
   exit 1
fi
smtpuser=""
read -p "Please input smtpuser:" smtpuser
if [ "$smtpuser" = "" ]; then
   echo "Error: smtpuser Can't be empty!!"
   exit 1
fi
smtppasswd=""
read -p "Please input smtppasswd:" smtppasswd
if [ "$smtppasswd" = "" ]; then
   echo "Error: smtppasswd Can't be empty!!"
   exit 1
fi

get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
echo ""
echo "Press any key to start create git host..."
char=`get_char`

sed -i '/# set from=/a\set from='$smtpuser'' /usr/local/mutt/etc/Muttrc
sed -i '/# set use_from=yes/a\set use_from=yes' /usr/local/mutt/etc/Muttrc
sed -i '/# set realname=""/a\set realname="DaoBiDao SyStem Mail"' /usr/local/mutt/etc/Muttrc
sed -i '/# set smtp_pass=""/a\set smtp_pass='$smtppasswd'' /usr/local/mutt/etc/Muttrc
sed -i '/# set smtp_url=""/a\set smtp_url=smtps://'$smtpuser'@'$smtphost':'$smtpport'/' /usr/local/mutt/etc/Muttrc
sed -i '/# set use_envelope_from=no/a\set use_envelope_from=yes' /usr/local/mutt/etc/Muttrc
sed -i '/# set editor=""/a\set editor="DaoBiDao"' /usr/local/mutt/etc/Muttrc
sed -i '/# set charset=""/a\set charset="utf-8"' /usr/local/mutt/etc/Muttrc
sed -i '/# set copy=yes/a\set copy=no' /usr/local/mutt/etc/Muttrc

fi
