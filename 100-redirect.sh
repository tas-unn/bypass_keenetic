#!/bin/sh
# shellcheck disable=SC2154
[ "$type" = "ip6tables" ] && exit 0
ip4t() {
    # shellcheck disable=SC2039
    if ! iptables -C "$@" &>/dev/null; then
        iptables -A "$@"
    fi
}
if [ -z "$(iptables-save 2>/dev/null | grep unblocksh)" ]; then
    ipset create unblocksh hash:net -exist
    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
fi


if [ -z "$(iptables-save 2>/dev/null | grep "udp --dport 53 -j DNAT")" ]; then
    iptables -w -t nat -I PREROUTING -i br0 -p udp --dport 53 -j DNAT --to 192.168.1.1
    iptables -w -t nat -I PREROUTING -i sstp0 -p udp --dport 53 -j DNAT --to 192.168.1.1
fi
if [ -z "$(iptables-save 2>/dev/null | grep "tcp --dport 53 -j DNAT")" ]; then
    iptables -w -t nat -I PREROUTING -i br0 -p tcp --dport 53 -j DNAT --to 192.168.1.1
    iptables -w -t nat -I PREROUTING -i sstp0 -p tcp --dport 53 -j DNAT --to 192.168.1.1
fi


if [ -z "$(iptables-save 2>/dev/null | grep unblocktor)" ]; then
    ipset create unblocktor hash:net -exist
    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
    iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141

    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
    iptables -t nat -A PREROUTING -i sstp0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141

fi


if [ -z "$(iptables-save 2>/dev/null | grep unblockvmess)" ]; then
    ipset create unblockvmess hash:net -exist
    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
    iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810

    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
    iptables -t nat -A PREROUTING -i sstp0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810

fi

if [ -z "$(iptables-save 2>/dev/null | grep unblocktroj)" ]; then
    ipset create unblocktroj hash:net -exist
    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
    iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829

    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
    iptables -t nat -A PREROUTING -i sstp0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829

fi


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