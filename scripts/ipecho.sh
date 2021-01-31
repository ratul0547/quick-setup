#!/bin/bash
 
PUBLIC_IP=`wget http://ipecho.net/plain -O - -q ; echo`
echo -e '\n'Your public IP is: '\033[1;93m'$PUBLIC_IP'\n'
