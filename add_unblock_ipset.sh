# не актуальное
## unblockvpn - множество
## vpn1.txt - название файла со списком обхода
#
#while read -r line || [ -n "$line" ]; do
#
#  [ -z "$line" ] && continue
#  #[ "${line:0:1}" = "#" ] && continue
#  [ "${line#?}" = "#" ] && continue
#
#  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}')
#
#  if [ -n "$cidr" ]; then
#    ipset -exist add unblockvpn "$cidr"
#    continue
#  fi
#
#  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
#
#  if [ -n "$range" ]; then
#    ipset -exist add unblockvpn "$range"
#    continue
#  fi
#
#  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
#
#  if [ -n "$addr" ]; then
#    ipset -exist add unblockvpn "$addr"
#    continue
#  fi
#
#  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblockvpn "$1)}'
#
#
#done < /opt/etc/unblock/vpn1.txt
