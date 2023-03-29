#!/bin/sh
[ "$1" != "start" ] && exit 0
ipset create unblocksh hash:net -exist
ipset create unblocktor hash:net -exist
ipset create unblockvmess hash:net -exist
ipset create unblocktroj hash:net -exist
ipset create unblockvpn hash:net -exist
for vpn_file_names in /opt/etc/unblock/vpn-*; do
vpn_file_name=$(echo "$vpn_file_names" | awk -F '/' '{print $5}' | sed 's/.txt//')
unblockvpn=$(echo unblock"$vpn_file_name")
ipset create "$unblockvpn" hash:net -exist
done

#script0
#script1
#script2
#script3
#script4
#script5
#script6
#script7
#script8
#script9
exit 0