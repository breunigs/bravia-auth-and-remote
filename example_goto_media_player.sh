#!/bin/bash

set -e

cd $(dirname $0)

if [ "$1" = "" ]; then
  echo "Usage: $0 <TV_IP>"
  exit 1
fi

if ! [ -e 'auth_cookie' ]; then
  echo 'auth_cookie not found. Run ./auth.sh first.'
  exit 1
fi

declare -A commandmap
commandmap[DIGITAL]="AAAAAgAAAJcAAAAyAw=="
commandmap[EXIT]="AAAAAQAAAAEAAABjAw=="
commandmap[HOME]="AAAAAQAAAAEAAABgAw=="
commandmap[DOWN]="AAAAAQAAAAEAAAB1Aw=="
commandmap[UP]="AAAAAQAAAAEAAAB0Aw=="
commandmap[LEFT]="AAAAAQAAAAEAAAA0Aw=="
commandmap[CONFIRM]="AAAAAQAAAAEAAABlAw=="
commandmap[ENTER]="AAAAAQAAAAEAAAALAw=="

tv_ip=$1

remote() {
  echo -n "$1: "
  ./send_command.sh $tv_ip ${commandmap[$1]}
}

 # get into known state
remote 'DIGITAL'

sleep 4
echo 'Waiting for TV to boot fully…'
sleep 30

remote 'HOME'
sleep 6

# select 'media player in lower left corner'
remote 'DOWN'
remote 'DOWN'
remote 'LEFT'
remote 'CONFIRM'
