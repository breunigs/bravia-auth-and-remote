#!/bin/sh

set -e

cd $(dirname $0)

if [ "$1" = "" ]; then
  echo "Usage: $0 <TV_IP>"
  exit 1
fi

curl --silent -XPOST http://$1/sony/system -d '{"id":4,"method":"getPowerStatus","version":"1.0","params":["1.0"]}' | python -m json.tool
