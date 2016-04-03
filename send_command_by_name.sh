#!/bin/bash

set -e

tv_ip="$1"
command="$2"

if [ "$tv_ip" = "" ] || [ "$command" = "" ]; then
  echo "Usage: $0 <TV_IP> <IRCC_COMMAND>"
  exit 1
fi

code_file='auth_cookie_examples/ircc_command_list'

if [ ! -f ${code_file} ]; then
    ./print_ircc_codes.sh ${tv_ip} > ${code_file}
fi

ircc=$(grep -i -A 1 $command ${code_file} | tail -n 1 | awk '{ print $2 }' | sed -e 's/"//g')

ping -n 1 ${tv_ip} > /dev/null
mac=$(arp -a | grep ${tv_ip} | awk '{ print $2 }')
wakeonlan ${mac} ${tv_ip} 255.255.255.0 7

if [ "$command" = "wake" ]; then
    exit 0
fi

if [ -z $ircc ]; then
    echo "Command not found: $command"
    exit 1
fi

./auth_cookie_examples/tv_challenge

cmd="<?xml version=\"1.0\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:X_SendIRCC xmlns:u=\"urn:schemas-sony-com:service:IRCC:1\"><IRCCCode>${ircc}</IRCCCode></u:X_SendIRCC></s:Body></s:Envelope>"

code=$(curl -w "%{http_code}" --user :${tv_challenge} --silent -XPOST http://${tv_ip}/sony/IRCC -d "$cmd" -H 'Content-Type: text/xml; charset=UTF-8' -H 'SOAPACTION: "urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"' -o /dev/null )

if [ "$code" = "200" ]; then
  echo "✓"
else
  echo "Command failed (HTTP_CODE: $code, try running it in a console)"
  exit 1
fi
