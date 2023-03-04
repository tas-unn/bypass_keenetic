#не актуальное
##vpn1 и unblockvpn меняем
#while read -r line || [ -n "$line" ]; do
#
#  [ -z "$line" ] && continue
#  #[ "${line:0:1}" = "#" ] && continue
#  [ "${line#?}" = "#" ] && continue
#
#  echo $line | grep -Eq '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' && continue
#
#  echo "ipset=/$line/unblockvpn" >> /opt/etc/unblock.dnsmasq
#  echo "server=/$line/127.0.0.1#40500" >> /opt/etc/unblock.dnsmasq
#done < /opt/etc/unblock/vpn1.txt
