#!/bin/sh

set -e

cd $(dirname $0)

if [ "$1" = "" ]; then
  echo "Usage: $0 <TV_IP>"
  exit 1
fi

if [ -e 'auth_cookie' ]; then
  read cookie < auth_cookie

  curl --silent --cookie \"$cookie\" -XPOST http://$1/sony/system -d '{"method":"getRemoteControllerInfo","params":[],"id":10,"version":"1.0"}'  | python -m json.tool
else
  echo 'auth_cookie not found. Run ./auth.sh first.'
fi
