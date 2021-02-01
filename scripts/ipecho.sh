#!/bin/bash
PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
HOSTNAME=`hostname -I`

echo -e '\n''\033[1;32m'Your public IP is:'	' '\033[1;93m'$PUBLIC_IP;
echo -e '\033[1;32m'Your local IP is:'	' '\033[1;36m'$HOSTNAME'\n';

