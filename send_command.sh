#!/bin/sh

set -e

cd $(dirname $0)

if [ "$1" = "" ]; then
  echo "Usage: $0 <TV_IP> <IRCC_COMMAND>"
  exit 1
fi

if ! [ -e 'auth_cookie' ]; then
  echo 'auth_cookie not found. Run ./auth.sh first.'
  exit 1
fi

read cookie < auth_cookie

cmd="<?xml version=\"1.0\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:X_SendIRCC xmlns:u=\"urn:schemas-sony-com:service:IRCC:1\"><IRCCCode>$2</IRCCCode></u:X_SendIRCC></s:Body></s:Envelope>"


code=$(curl -w "%{http_code}" --silent -XPOST http://$1/sony/IRCC -d "$cmd" -H 'Content-Type: text/xml; charset=UTF-8' -H 'SOAPACTION: "urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"' -H "Cookie: $cookie" -o /dev/null )

if [ "$code" = "200" ]; then
  echo "✓"
else
  echo "Command failed (HTTP_CODE: $code, try running it in a console)"
  exit 1
fi
