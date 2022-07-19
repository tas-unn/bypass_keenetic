#!/bin/sh
ipset flush unblocktor
ipset flush unblocksh
#ipset flush unblockvpn # добавляем столько сколько надо
/opt/bin/unblock_dnsmasq.sh
/opt/etc/init.d/S56dnsmasq restart
/opt/bin/unblock_ipset.sh &
