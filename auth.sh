#!/bin/sh

set -e

tv_ip=''

# use only A-Z a-z 0-9 for device. Probably. Haven't checked.
my_device=''
my_nick=''

my_uuid=$(uuidgen)



cd $(dirname $0)

if [ -e 'auth_cookie' ]; then
  echo "There's already an auth_cookie file. Delete the file to continue."
  exit 1
fi

if [ "$tv_ip" = "" ] || [ "$my_nick" = "" ] || [ "$my_device" = "" ]; then
  echo "Missing configuration data, please edit the script and run it again."
  exit 2
fi


echo "-------------------------------"
echo "Trying to register on $tv_ip…"
curl --silent -XPOST http://$tv_ip/sony/accessControl -d "{\"method\":\"actRegister\",\"params\":[{\"clientid\":\"$my_nick:$my_uuid\",\"nickname\":\"$my_nick ($my_device)\",\"level\":\"private\"},[{\"value\":\"yes\",\"function\":\"WOL\"}]],\"id\":8,\"version\":\"1.0\"}"
echo "\n\n"

echo 'Response should contain an "Unauthorized" error and the TV should display'
echo 'a dialog with a 4-digit PIN.'
echo 'A message with "Registration has been cancelled" after this step means'
echo 'that the UUID seems to be registered already.'
echo 'Delete old registered devices in:'
echo 'Settings → Network → Home Network Setup → Remote Device / Renderer'
echo '  → Registered Remote Devices'

echo "\n\n"
echo "Okay, now enter the 4-digit code shown on the TV:"
read tv_challenge
echo "\n\n"

tv_auth_header="Authorization: Basic $(echo -n ":$tv_challenge" | base64)"

echo "-------------------------------"
echo "Trying to register on $tv_ip, this time with the given code…"
echo "\n\n"
cookie=$(curl --include --silent -XPOST http://$tv_ip/sony/accessControl --header "$tv_auth_header" -d "{\"method\":\"actRegister\",\"params\":[{\"clientid\":\"$my_nick:$my_uuid\",\"nickname\":\"$my_nick ($my_device)\",\"level\":\"private\"},[{\"value\":\"yes\",\"function\":\"WOL\"}]],\"id\":8,\"version\":\"1.0\"}" | grep -o -E 'auth=([a-z0-9]+)')
echo $cookie

echo $cookie > 'auth_cookie'


echo "\n\n"
echo "If everything worked, you should see an auth=<code> line above."
echo "Your computer is now registered, use it like this:"
echo "\n"
echo "   curl --cookie \"$cookie\" -XPOST http://$tv_ip/sony/system -d '<JSON STUFF>'"

echo
echo
./print_ircc_codes.sh $tv_ip > ircc_command_list
echo "Available IRCC commands have been saved to 'ircc_command_list'"
echo
echo "Run a IRCC command with: ./send_command.sh $tv_ip <IRCC-Code>"
