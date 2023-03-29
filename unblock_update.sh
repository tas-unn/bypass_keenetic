#!/bin/sh
ipset flush unblocktor
ipset flush unblocksh
ipset flush unblockvmess
ipset flush unblocktroj
#ipset flush unblockvpn
for vpn_file_names in /opt/etc/unblock/vpn-*; do
vpn_file_name=$(echo "$vpn_file_names" | awk -F '/' '{print $5}' | sed 's/.txt//')
# shellcheck disable=SC2116
unblockvpn=$(echo unblock"$vpn_file_name")
ipset flush "$unblockvpn"
done
/opt/bin/unblock_dnsmasq.sh
/opt/etc/init.d/S56dnsmasq restart
/opt/bin/unblock_ipset.sh &