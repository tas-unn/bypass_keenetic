#!/bin/sh

until ADDRS=$(dig +short google.com @localhost -p 40500) && [ -n "$ADDRS" ] > /dev/null 2>&1; do sleep 5; done

while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  #[ "${line:0:1}" = "#" ] && continue
  # [ "$(echo "$line" | cut -c 1)" = "#" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')

  if [ -n "$cidr" ]; then
    ipset -exist add unblocksh "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  if [ -n "$range" ]; then
    ipset -exist add unblocksh "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  if [ -n "$addr" ]; then
    ipset -exist add unblocksh "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocksh "$1)}'

done < /opt/etc/unblock/shadowsocks.txt

while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  # [ "${line:0:1}" = "#" ] && continue
  #[ "$(echo "$line" | cut -c 1)" = "#" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')

  if [ -n "$cidr" ]; then
    ipset -exist add unblocktor "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  if [ -n "$range" ]; then
    ipset -exist add unblocktor "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  if [ -n "$addr" ]; then
    ipset -exist add unblocktor "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocktor "$1)}'



done < /opt/etc/unblock/tor.txt

while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  #[ "${line:0:1}" = "#" ] && continue
  #[ "$(echo "$line" | cut -c 1)" = "#" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')

  if [ -n "$cidr" ]; then
    ipset -exist add unblockvmess "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  if [ -n "$range" ]; then
    ipset -exist add unblockvmess "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  if [ -n "$addr" ]; then
    ipset -exist add unblockvmess "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblockvmess "$1)}'



done < /opt/etc/unblock/vmess.txt

while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  #[ "${line:0:1}" = "#" ] && continue
  #[ "$(echo "$line" | cut -c 1)" = "#" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')

  if [ -n "$cidr" ]; then
    ipset -exist add unblocktroj "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  if [ -n "$range" ]; then
    ipset -exist add unblocktroj "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

  if [ -n "$addr" ]; then
    ipset -exist add unblocktroj "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocktroj "$1)}'



done < /opt/etc/unblock/trojan.txt
#script0
