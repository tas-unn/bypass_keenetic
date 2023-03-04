#!/bin/sh

# 2023. Keenetic DNS bot /  Проект: bypass_keenetic / Автор: tas_unn
# GitHub: https://github.com/tas-unn/bypass_keenetic
# Данный бот предназначен для управления обхода блокировок на роутерах Keenetic
# Демо-бот: https://t.me/keenetic_dns_bot
#
# Файл: 100-unblock-vpn.sh, Версия 2.1.0, последнее изменение: 04.03.2023, 18:54
# Автор файла: NetworK (https://github.com/ziwork)

check_vpn=$(curl -s localhost:79/rci/show/ip/name-server | grep service | grep -wv Dns | awk '{print $2}' | tr -d \", | sort -u)
for vpn in $check_vpn ; do

echo "$vpn"

[ "$1" = "hook" ] || exit 0
[ "$change" = "link" ] || exit 0
[ "$id" = "$vpn" ] || exit 0

vpn_name=$vpn
vpn_type=$(curl -s localhost:79/rci/show/ip/name-server | grep -wv 8.8 | grep "$vpn_name" -B5 | grep address | awk '{print $2}' | tr -d \",)
vpn_ip_route=$(ip route list | grep "$vpn_type" | awk '{print $3}')

IF_NAME=$vpn_ip_route
IF_GW4=$(ip -4 addr show "$IF_NAME" | grep -Po "(?<=inet ).*(?=/)" | awk '{print $1}')

case ${id}-${change}-${connected}-${link}-${up} in
     ${id}-link-no-down-down)
        ip -4 rule del fwmark 0xd1000 lookup 1001 priority 1778 2>/dev/null
        ip -4 route flush table 1001
     ;;
     ${id}-link-yes-up-up)
        ip -4 route add table 1001 default via "$IF_GW4" dev "$IF_NAME" 2>/dev/null
        ip -4 route show table main | grep -Ev ^default | while read -r ROUTE; do ip -4 route add table 1001 "$ROUTE" 2>/dev/null; done
        ip -4 rule add fwmark 0xd1000 lookup 1001 priority 1778 2>/dev/null
        ip -4 route flush cache
     ;;
esac

done

exit 0