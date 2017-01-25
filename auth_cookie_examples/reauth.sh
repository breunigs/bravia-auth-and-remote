#!/bin/sh

# Note: this is only useful when you want to build an APP that also supports
#       authentication via cookie. You must have run auth.sh and have a saved UUID.

set -e

cd $(dirname $0)

. ./bravia.cfg

if [ ! -e 'uuid' ]; then
  echo "There is no uuid file. Run auth.sh to generate one."
  exit 1
fi

read my_uuid <  'uuid'

if [ "$tv_ip" = "" ] || [ "$my_nick" = "" ] || [ "$my_device" = "" ] || [ "$my_uuid" = "" ]; then
  echo "Missing configuration data, please edit the script and run it again."
  exit 2
fi

data="{\"method\":\"actRegister\",\"params\":[{\"clientid\":\"$my_nick:$my_uuid\",\"nickname\":\"$my_nick ($my_device)\",\"level\":\"private\"},[{\"value\":\"yes\",\"function\":\"WOL\"}]],\"id\":8,\"version\":\"1.0\"}"

echo "-------------------------------"
echo "Trying to reauthorise and get a new cookie..."
echo;echo

cookie=$(curl --include --silent -XPOST http://$tv_ip/sony/accessControl -d "$data" | grep -o -E 'auth=([A-Za-z0-9]+)')
echo $cookie

echo $cookie > 'auth_cookie'

echo;echo
echo "If everything worked, you should see an auth=<code> line above."
echo "Your computer is now registered, use it like this:"
echo
echo "   curl --cookie \"$cookie\" -XPOST http://$tv_ip/sony/system -d '<JSON STUFF>'"

# Uncomment this to capture the MAC address
#echo;echo
#echo "Saving MAC address. This useful to implement Wake-on-LAN"
#mac=$(arp -a | grep ${tv_ip} | awk '{ print $4 }')
#echo $mac > 'mac'
