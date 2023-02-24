#!/bin/sh

set -e

if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]; then
  echo "Usage: $0 <TV_IP> <TV_PIN> <IRCC_COMMAND>"
  exit 1
fi

cmd="<?xml version=\"1.0\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:X_SendIRCC xmlns:u=\"urn:schemas-sony-com:service:IRCC:1\"><IRCCCode>$3</IRCCCode></u:X_SendIRCC></s:Body></s:Envelope>"

code=$(curl -w "%{http_code}" --silent -XPOST http://$1/sony/IRCC -d "$cmd" -H 'Content-Type: text/xml; charset=UTF-8' -H 'SOAPACTION: "urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"' -H "X-Auth-PSK: $2" -o /dev/null )

if [ "$code" = "200" ]; then
  echo "✓"
else
  echo "Command failed (HTTP_CODE: $code, try running it in a console)"
  exit 1
fi
