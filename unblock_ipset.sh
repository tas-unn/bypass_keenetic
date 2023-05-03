#!/bin/sh

# 2023. Keenetic DNS bot /  Проект: bypass_keenetic / Автор: tas_unn
# GitHub: https://github.com/tas-unn/bypass_keenetic
# Данный бот предназначен для управления обхода блокировок на роутерах Keenetic
# Демо-бот: https://t.me/keenetic_dns_bot
#
# Файл: unblock_ipset.sh, Версия 2.1.9, последнее изменение: 03.05.2023, 22:03
# Доработал: NetworK (https://github.com/ziwork)

cut_local() {
	grep -vE 'localhost|^0\.|^127\.|^10\.|^172\.16\.|^192\.168\.|^::|^fc..:|^fd..:|^fe..:'
}

until ADDRS=$(dig +short google.com @localhost -p 40500) && [ -n "$ADDRS" ] > /dev/null 2>&1; do sleep 5; done

while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | cut_local)

  if [ -n "$cidr" ]; then
    ipset -exist add unblocksh "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$range" ]; then
    ipset -exist add unblocksh "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$addr" ]; then
    ipset -exist add unblocksh "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocksh "$1)}'

done < /opt/etc/unblock/shadowsocks.txt


while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | cut_local)

  if [ -n "$cidr" ]; then
    ipset -exist add unblocktor "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$range" ]; then
    ipset -exist add unblocktor "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$addr" ]; then
    ipset -exist add unblocktor "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocktor "$1)}'

done < /opt/etc/unblock/tor.txt


while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | cut_local)

  if [ -n "$cidr" ]; then
    ipset -exist add unblockvmess "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$range" ]; then
    ipset -exist add unblockvmess "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$addr" ]; then
    ipset -exist add unblockvmess "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblockvmess "$1)}'

done < /opt/etc/unblock/vmess.txt


while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | cut_local)

  if [ -n "$cidr" ]; then
    ipset -exist add unblocktroj "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$range" ]; then
    ipset -exist add unblocktroj "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$addr" ]; then
    ipset -exist add unblocktroj "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocktroj "$1)}'

done < /opt/etc/unblock/trojan.txt

if ls -d /opt/etc/unblock/vpn-*.txt >/dev/null 2>&1; then
for vpn_file_names in /opt/etc/unblock/vpn-*; do
vpn_file_name=$(echo "$vpn_file_names" | awk -F '/' '{print $5}' | sed 's/.txt//')
unblockvpn=$(echo unblock"$vpn_file_name")
if [ -n '$(ipset list | grep "unblockvpn-")' ] ; then  ipset create "$unblockvpn" hash:net -exist; fi
cat "$vpn_file_names" | while read -r line || [ -n "$line" ]; do
  [ -z "$line" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | cut_local)
  if [ -n "$cidr" ]; then
    ipset -exist add "$unblockvpn" "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)
  if [ -n "$range" ]; then
    ipset -exist add "$unblockvpn" "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)
  if [ -n "$addr" ]; then
    ipset -exist add "$unblockvpn" "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk -v unblockvpn="$unblockvpn" '{system("ipset -exist add " unblockvpn " " $1)}'
done
done
fi

# unblockvpn - множество
# vpn1.txt - название файла со списком обхода

#while read -r line || [ -n "$line" ]; do
#  [ -z "$line" ] && continue
#  [ "${line#?}" = "#" ] && continue
#
#  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | cut_local)
#  if [ -n "$cidr" ]; then
#    ipset -exist add unblockvpn "$cidr"
#    continue
#  fi
#
#  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)
#  if [ -n "$range" ]; then
#    ipset -exist add unblockvpn "$range"
#    continue
#  fi
#
#  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)
#  if [ -n "$addr" ]; then
#    ipset -exist add unblockvpn "$addr"
#    continue
#  fi
#
#  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblockvpn "$1)}'
#done < /opt/etc/unblock/vpn.txt