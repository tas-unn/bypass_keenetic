# не актуальное
#if [ -z "$(iptables-save 2>/dev/null | grep unblockvpn)" ]; then
#    ipset create unblockvpn hash:net -exist
#    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1
#    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1
#    iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1
#    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1
#
#    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1
#    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1
#    iptables -t nat -A PREROUTING -i sstp0 -p tcp -m set --match-set unblockvpn dst -j MASQUERADE -o ppp1
#
#fi
#exit 0
