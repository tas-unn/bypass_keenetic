#!/bin/sh
ipset flush unblocktor
ipset flush unblocksh
/opt/bin/unblock_dnsmasq.sh
/opt/etc/init.d/S56dnsmasq restart
/opt/bin/unblock_ipset.sh &
