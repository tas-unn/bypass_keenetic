#!/bin/sh

# 2023. Keenetic DNS bot /  Проект: bypass_keenetic / Автор: tas_unn
# GitHub: https://github.com/tas-unn/bypass_keenetic
# Данный бот предназначен для управления обхода блокировок на роутерах Keenetic
# Демо-бот: https://t.me/keenetic_dns_bot
#
# Файл: 100-redirect.sh, Версия 2.1.0, последнее изменение: 04.03.2023, 18:30
# Доработал: NetworK (https://github.com/ziwork)

# shellcheck disable=SC2154
[ "$type" = "ip6tables" ] && exit 0
[ "$table" != "mangle" ] && exit 0
ip4t() {
    # shellcheck disable=SC2039
    if ! iptables -C "$@" &>/dev/null; then
        iptables -A "$@"
    fi
}

# shellcheck disable=SC2143
if [ -z "$(iptables-save 2>/dev/null | grep unblocksh)" ]; then
    ipset create unblocksh hash:net -exist
    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
fi

# shellcheck disable=SC2143
if [ -z "$(iptables-save 2>/dev/null | grep "udp --dport 53 -j DNAT")" ]; then
    iptables -w -t nat -I PREROUTING -i br0 -p udp --dport 53 -j DNAT --to 192.168.1.1
    iptables -w -t nat -I PREROUTING -i sstp0 -p udp --dport 53 -j DNAT --to 192.168.1.1
fi
# shellcheck disable=SC2143
if [ -z "$(iptables-save 2>/dev/null | grep "tcp --dport 53 -j DNAT")" ]; then
    iptables -w -t nat -I PREROUTING -i br0 -p tcp --dport 53 -j DNAT --to 192.168.1.1
    iptables -w -t nat -I PREROUTING -i sstp0 -p tcp --dport 53 -j DNAT --to 192.168.1.1
fi

# shellcheck disable=SC2143
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

# shellcheck disable=SC2143
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

# shellcheck disable=SC2143
if [ -z "$(iptables-save 2>/dev/null | grep unblocktroj)" ]; then
    ipset create unblocktroj hash:net -exist
    iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10810
    iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10810
    iptables -t nat -A PREROUTING -i br0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10810
    iptables -t nat -A OUTPUT -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10810

    iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10810
    iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10810
    iptables -t nat -A PREROUTING -i sstp0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10810

fi

# add block iptables from vpn by ziwork
# shellcheck disable=SC2143
if [ -z "$(iptables-save 2>/dev/null | grep unblockvpn)" ]; then
	ipset create unblockvpn hash:net -exist
	# С отключением fastnat и ускорителей
	#iptables -I PREROUTING -w -t mangle -i br0 -p tcp -m set --match-set unblockvpn dst -j MARK --set-mark 0xd1000
	#iptables -I PREROUTING -w -t mangle -i br0 -p udp -m set --match-set unblockvpn dst -j MARK --set-mark 0xd1000
	#iptables -t mangle -A OUTPUT -p tcp -m set --match-set unblockvpn dst -j MARK --set-mark 0xd1000

	# Без отключения
	iptables -I PREROUTING -w -t mangle -m conntrack --ctstate NEW -m set --match-set unblockvpn dst -j CONNMARK --set-mark 0xd1000
	iptables -I PREROUTING -w -t mangle -j CONNMARK --restore-mark
	iptables -t mangle -A OUTPUT -p tcp -m set --match-set unblockvpn dst -j CONNMARK --set-mark 0xd1000
fi

#script0
#script1
#script2
#script3

exit 0
