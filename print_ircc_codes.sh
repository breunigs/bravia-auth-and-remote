#!/bin/sh

set -e

cd $(dirname $0)

if [ "$1" = "" ]; then
  echo "Usage: $0 <TV_IP>"
  exit 1
fi

curl --silent -XPOST http://$1/sony/system -d '{"method":"getRemoteControllerInfo","params":[],"id":10,"version":"1.0"}'  | python -m json.tool
