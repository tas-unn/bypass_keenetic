#!/bin/sh
[ "$1" != "start" ] && exit 0
ipset create unblocksh hash:net -exist
ipset create unblocktor hash:net -exist
exit 0
