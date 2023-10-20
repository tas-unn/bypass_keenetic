#!/bin/sh

# 2023. Keenetic DNS bot /  Проект: bypass_keenetic / Автор: tas_unn
# GitHub: https://github.com/tas-unn/bypass_keenetic
# Данный бот предназначен для управления обхода блокировок на роутерах Keenetic
# Демо-бот: https://t.me/keenetic_dns_bot
#
# Файл: 100-unblock-vpn-v4.sh, Версия 2.2.0, последнее изменение: 01.10.2023, 18:58
# Автор файла: NetworK (https://github.com/ziwork)

TAG="100-unblock-vpn.sh"

sleep 1
check_allow_vpn_in_config=$(grep "vpn_allowed" /opt/etc/bot_config.py | head -1 | sed 's/=/ /g' | tr -d '\"' | awk '{print $2}')
if [ -z "${check_allow_vpn_in_config}" ]; then
    vpn_services="IKE|SSTP|OpenVPN|Wireguard|L2TP"
else
    vpn_services=$(echo "$check_allow_vpn_in_config")
fi
vpn_check=$(curl -s localhost:79/rci/show/interface | grep -E "$vpn_services" | grep id | awk '{print $2}' | tr -d \", | uniq -u)

mkdir -p /opt/etc/iproute2
touch /opt/etc/iproute2/rt_tables
chmod 755 /opt/etc/iproute2/rt_tables

for vpn in $vpn_check ; do
#logger -t "$TAG" "$vpn"
if [ "$1" = "hook" ] && [ "$change" = "connected" ] && [ "$id" = "$vpn" ]; then

# shellcheck disable=SC2060
vpn_table=$(echo "$vpn" | tr [:upper:] [:lower:]) # sed 's/[A-Z]/\L&/g'
  if grep -q "$vpn_table" /opt/etc/iproute2/rt_tables; then
      echo "Таблица уже есть"
  else
      echo "Таблицы нет, создаем"
      get_last_fwmark_id=$(tail -1 /opt/etc/iproute2/rt_tables | awk '{print $1}')
      if [ -n "${get_last_fwmark_id}" ]; then counter_new=$(($get_last_fwmark_id + 1)); else counter_new=$((1000 + 1)); fi
      vpn_table_file=$(echo "$counter_new" "$vpn_table")
      echo "$vpn_table_file" >> /opt/etc/iproute2/rt_tables
  fi

  sleep 1
  vpn_table_id=$(grep "$vpn_table" /opt/etc/iproute2/rt_tables | awk '{print $1}')
  get_fwmark_id=$(grep "$vpn_table" /opt/etc/iproute2/rt_tables | awk '{print "0xd"$1}')
  vpn_link_up=$(curl -s localhost:79/rci/show/interface/"$vpn"/connected | tr -d '"')

  if [ "$vpn_link_up" = "no" ]; then
      info=$(echo VPN "$vpn" OFF: правила обновлены)
      logger -t "$TAG" "$info"
      ip rule del from all table "$vpn_table_id" priority 1778 2>/dev/null
      ip -4 rule del fwmark "$get_fwmark_id" lookup "$vpn_table_id" priority 1778 2>/dev/null
      ip -4 route flush table "$vpn_table_id"
      type=iptable table=nat /opt/etc/ndm/netfilter.d/100-redirect.sh

      #cat /dev/null >| /opt/etc/iproute2/rt_tables
      #sed -i '/"$vpn_table_file"/d' /opt/etc/iproute2/rt_tables
  fi

  sleep 2

  if [ "$vpn_link_up" = "yes" ]; then
      sleep 3
      vpn_ip=$(curl -s localhost:79/rci/show/interface/"$vpn"/address | tr -d \")
      vpn_type=$(ifconfig | grep "$vpn_ip" -B1 | head -1 |cut -d " " -f1)
      vpn_name=$(curl -s localhost:79/rci/show/interface/"$vpn"/description | tr -d \")
      unblockvpn=$(echo unblockvpn-"$vpn_name"-"$vpn")

      ip -4 route add table "$vpn_table_id" default via "$vpn_ip" dev "$vpn_type" 2>/dev/null
      ip -4 route show table main | grep -Ev ^default | while read -r ROUTE; do ip -4 route add table "$vpn_table_id" $ROUTE 2>/dev/null; done
      ip -4 rule add fwmark "$get_fwmark_id" lookup "$vpn_table_id" priority 1778 2>/dev/null
      ip -4 route flush cache
      touch /opt/etc/unblock/vpn-"$vpn_name"-"$vpn".txt
      chmod 0755 /opt/etc/unblock/vpn-"$vpn_name"-"$vpn".txt

      info=$(echo VPN "$vpn" ON: "$vpn_name" "$vpn_ip" via "$vpn_type")
      logger -t "$TAG" "$info"

      if iptables-save 2>/dev/null | grep -q "$unblockvpn"; then
        info_ipset=$(echo "ipset уже есть");
        logger -t "$TAG" "$info_ipset";
      else
        ipset create "$unblockvpn" hash:net -exist 2>/dev/null;
      fi
      type=iptable table=nat /opt/etc/ndm/netfilter.d/100-redirect.sh

      #/opt/bin/unblock_update.sh
      #log="$(ip route show table 1001 | wc -l) ips added to route table 1000"
      #echo "$log"
      #logger "$log"
  fi
fi # hook
done

exit 0