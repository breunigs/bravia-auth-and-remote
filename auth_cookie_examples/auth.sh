#!/bin/sh

# Note: this is only useful when you want to build an APP that also supports
#       authentication via cookie. The cookie method loses validity after a
#       couple of weeks, so you need to run reauth.sh some time before that.

set -e

my_uuid=$(uuidgen)

cd $(dirname $0)

. ./bravia.cfg

if [ -e 'auth_cookie' ]; then
  echo "There's already an auth_cookie file. Delete the file to continue."
  exit 1
fi

if [ "$tv_ip" = "" ] || [ "$my_nick" = "" ] || [ "$my_device" = "" ]; then
  echo "Missing configuration data, please edit the script and run it again."
  exit 2
fi

data="{\"method\":\"actRegister\",\"params\":[{\"clientid\":\"$my_nick:$my_uuid\",\"nickname\":\"$my_nick ($my_device)\",\"level\":\"private\"},[{\"value\":\"yes\",\"function\":\"WOL\"}]],\"id\":8,\"version\":\"1.0\"}"

echo "-------------------------------"
echo "Trying to register on $tv_ip..."
curl --silent -XPOST http://$tv_ip/sony/accessControl -d "$data"
echo;echo

echo 'Response should contain an "Unauthorized" error and the TV should display'
echo 'a dialog with a 4-digit PIN.'
echo 'A message with "Registration has been cancelled" after this step means'
echo 'that the UUID seems to be registered already.'
echo 'Delete old registered devices in:'
echo 'Settings -> Network -> Home Network Setup -> Remote Device / Renderer'
echo '  -> Registered Remote Devices'

echo;echo
echo "Okay, now enter the 4-digit code shown on the TV:"
read tv_challenge
echo "export tv_challenge=${tv_challenge}" > 'tv_challenge'
echo;echo

echo "-------------------------------"
echo "Trying to register on $tv_ip, this time with the given code..."
echo;echo

cookie=$(curl --include --silent -XPOST http://$tv_ip/sony/accessControl --user :$tv_challenge -d "$data" | grep -o -E 'auth=([A-Za-z0-9]+)')
echo $cookie

echo $cookie > 'auth_cookie'
echo $my_uuid > 'uuid'

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

echo;echo
../print_ircc_codes.sh $tv_ip > ircc_command_list
echo "Available IRCC commands have been saved to 'ircc_command_list'"
echo
echo "Run a IRCC command with: ./example_curl.sh $tv_ip <IRCC-Code>"
