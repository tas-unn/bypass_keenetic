#!/bin/sh

until ADDRS=$(dig +short google.com @localhost -p 40500) && [ -n "$ADDRS" ] > /dev/null 2>&1; do sleep 5; done
while read line || [ -n "$line" ]; do
  [ -z "$line" ] && continue
  [ "${line:0:1}" = "#" ] && continue
  cidr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')
  if [ ! -z "$cidr" ]; then
    ipset -exist add unblocksh $cidr
    continue
  fi
  range=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
  if [ ! -z "$range" ]; then
    ipset -exist add unblocksh $range
    continue
  fi
  addr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
  if [ ! -z "$addr" ]; then
    ipset -exist add unblocksh $addr
    continue
  fi
  dig +short $line @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocksh "$1)}'
done < /opt/etc/unblocksh.txt

until ADDRS=$(dig +short google.com @localhost -p 40500) && [ -n "$ADDRS" ] > /dev/null 2>&1; do sleep 5; done
while read line || [ -n "$line" ]; do
  [ -z "$line" ] && continue
  [ "${line:0:1}" = "#" ] && continue
  cidr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')
  if [ ! -z "$cidr" ]; then
    ipset -exist add unblocktor $cidr
    continue
  fi
  range=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
  if [ ! -z "$range" ]; then
    ipset -exist add unblocktor $range
    continue
  fi
  addr=$(echo $line | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
  if [ ! -z "$addr" ]; then
    ipset -exist add unblocktor $addr
    continue
  fi
  dig +short $line @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocktor "$1)}'
done < /opt/etc/unblocktor.txt
