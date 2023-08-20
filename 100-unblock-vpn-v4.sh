#!/bin/sh

# 2023. Keenetic DNS bot /  Проект: bypass_keenetic / Автор: tas_unn
# GitHub: https://github.com/tas-unn/bypass_keenetic
# Данный бот предназначен для управления обхода блокировок на роутерах Keenetic
# Демо-бот: https://t.me/keenetic_dns_bot
#
# Файл: 100-unblock-vpn.sh, Версия 2.2.0, последнее изменение: 20.08.2023, 20:31
# Автор файла: NetworK (https://github.com/ziwork)

TAG="100-unblock-vpn.sh"

sleep 1
vpn_services="IKE|SSTP|OpenVPN|Wireguard|VPNL2TP"
vpn_check=$(curl -s localhost:79/rci/show/interface | grep -E "$vpn_services" | grep id | awk '{print $2}' | tr -d \", | uniq -u)
#vpn_check=$(ndmc -c "show interface" | grep -E "$vpn_services" | grep id | awk '{print $2}')
#vpn_check=$(curl -s localhost:79/rci/show/ip/name-server | grep service | grep -wv Dns | awk '{print $2}' | tr -d \", | sort -u)

mkdir -p /opt/etc/iproute2
touch /opt/etc/iproute2/rt_tables
chmod 755 /opt/etc/iproute2/rt_tables

for vpn in $vpn_check ; do
#logger -t "$TAG" "$vpn"

### for 3.9.8
#if [ "$1" = "hook" ] && [ "$change" = "link" ] && [ "$id" = "$vpn" ]; then
### for 4.0+
if [ "$1" = "hook" ] && [ "$change" = "connected" ] && [ "$id" = "$vpn" ]; then

# shellcheck disable=SC2060
vpn_table=$(echo "$vpn" | tr [:upper:] [:lower:]) # sed 's/[A-Z]/\L&/g'

if grep -q "$vpn_table" /opt/etc/iproute2/rt_tables; then
	  echo "Таблица уже есть"
else
	  echo "Таблицы нет, создаем"
	  get_last_fwmark_id=$(tail -1 /opt/etc/iproute2/rt_tables | awk '{print $1}')
	  if [ -n $get_last_fwmark_id ]; then counter_new=$(($get_last_fwmark_id + 1)); else counter_new=$((1000 + 1)); fi
	  vpn_table_file=$(echo "$counter_new" "$vpn_table")
	  echo "$vpn_table_file" >> /opt/etc/iproute2/rt_tables
fi

#fwmark_id=$(echo 0xd"$counter_new")

sleep 1
unblockvpn=$(echo unblockvpn-"$vpn_name"-"$vpn")
get_fwmark_id=$(grep "$vpn_table" /opt/etc/iproute2/rt_tables | awk '{print "0xd"$1}')

### for 3.9.8
#case ${id}-${change}-${connected}-${link}-${up} in
#    ${id}-link-no-down-down)

### for test 3.9 and 4.0+
#case ${id}-${change}-${connected}-${link}-${up} in
#    ${id}-connected-no-down-down)
#    ;;
#    ${id}-connected-yes-up-up)
#    ;;
#esac

### for 4.0+
#case ${connected}-${link}-${up} in
#	  no-down-down)
case ${id}-${change}-${connected}-${link}-${up} in
    ${id}-connected-no-down-down)
	  info=$(echo VPN "$vpn" OFF: правила обновлены)
	  logger -t "$TAG" "$info"
	  ip rule del from all table "$vpn_table" priority 1778 2>/dev/null
	  ip -4 rule del fwmark "$get_fwmark_id" lookup "$vpn_table" priority 1778 2>/dev/null
	  ip -4 route flush table "$vpn_table"
	  type=iptable table=nat /opt/etc/ndm/netfilter.d/100-redirect.sh

	  #cat /dev/null >| /opt/etc/iproute2/rt_tables
	  #sed -i '/"$vpn_table_file"/d' /opt/etc/iproute2/rt_tables
	  ;;

    ### for 3.9.8
    #${id}-link-yes-up-up)
    ### for 4.0+
    #yes-up-up)
    ${id}-connected-yes-up-up)
	  sleep 2
	  vpn_ip=$(curl -s localhost:79/rci/show/interface/"$vpn"/address | tr -d \")
	  # vpn_type=$(ip route list | grep "$vpn_ip" | awk '{print $3}' | grep -v "ss")
	  vpn_type=$(ifconfig | grep "$vpn_ip" -B1 | head -1 |cut -d " " -f1)
	  vpn_name=$(curl -s localhost:79/rci/show/interface/"$vpn"/description | tr -d \")

	  ip -4 route add table "$vpn_table" default via "$vpn_ip" dev "$vpn_type" 2>/dev/null
	  # ip -4 route show table main | grep -Ev ^default | while read -r ROUTE; do ip -4 route add table "$vpn_table" "$ROUTE" 2>/dev/null; done
	  ip -4 route show table main | grep -Ev ^default | while read -r ROUTE; do ip -4 route add table "$vpn_table" $ROUTE 2>/dev/null; done
	  ip -4 rule add fwmark "$get_fwmark_id" lookup "$vpn_table" priority 1778 2>/dev/null
	  ip -4 route flush cache
	  touch /opt/etc/unblock/vpn-"$vpn_name"-"$vpn".txt
	  chmod 0755 /opt/etc/unblock/vpn-"$vpn_name"-"$vpn".txt

	  info=$(echo VPN "$vpn" ON: "$vpn_name" "$vpn_ip" via "$vpn_type")
	  logger -t "$TAG" "$info"

	  if iptables-save 2>/dev/null | grep -q "$unblockvpn"; then
	  info_ipset=$(echo "ipset уже есть"); logger -t "$TAG" "$info_ipset" else ipset create "$unblockvpn" hash:net -exist; fi
	  type=iptable table=nat /opt/etc/ndm/netfilter.d/100-redirect.sh

	  #/opt/bin/unblock_update.sh
	  #log="$(ip route show table 1001 | wc -l) ips added to route table 1000"
	  #echo "$log"
	  #logger "$log"
    ;;
esac
fi # hook
done

exit 0