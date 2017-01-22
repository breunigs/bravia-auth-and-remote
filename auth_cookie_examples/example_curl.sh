#!/bin/sh

# Note: this is only useful when you want to build an APP that also supports
#       authentication via cookie. The cookie method loses validity after a
#       couple of weeks, so so there is probably some refresh method required
#       which is not detailed here.

if [ "$1" = "" ]; then
  echo "Usage: $0 <IRCC_COMMAND>"
  exit 1
fi

if ! [ -e 'auth_cookie' ]; then
  echo 'auth_cookie not found. Run ./auth.sh first.'
  exit 1
fi

if ! [ -e 'bravia.cfg' ]; then
  echo 'bravia.cfg not found.'
  exit 1
fi

. ./bravia.cfg

read cookie < auth_cookie

cmd="<?xml version=\"1.0\"?><s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><s:Body><u:X_SendIRCC xmlns:u=\"urn:schemas-sony-com:service:IRCC:1\"><IRCCCode>$1</IRCCCode></u:X_SendIRCC></s:Body></s:Envelope>"

curl --silent -XPOST http://$tv_ip/sony/IRCC -d "$cmd" -H 'Content-Type: text/xml; charset=UTF-8' -H 'SOAPACTION: "urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"' -H"Cookie: $cookie"
