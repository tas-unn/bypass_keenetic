#!/bin/sh

if [ "$1" == "remove" ]
then
	opkg remove wget wget-ssl mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config
	rmdir /opt/tmp/tor
  exit 0
fi

if [ "$1" == "install" ]
then
	echo "Начинаем установку"
	opkg update
	opkg install wget wget-ssl mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config
	#pip install --upgrade pip
	#pip install pytelegrambotapi
	#pip install paramiko
	echo "Установили пакеты"
	# есть поддержка множества hash:net или нет, если нет, то при этом вы потеряете возможность разблокировки по диапазону и CIDR
	set_type="hash:net"
	ipset create testset hash:net -exist > /dev/null 2>&1
	retVal=$?
	if [ $retVal -ne 0 ]; then
	  set_type="hash:ip"
	fi
	# ip роутера
	lanip=$(ndmq -c 'show interface Bridge0' -P address)
	ssredir="ss-redir"
	echo "Переменные роутера найдены"
	# создания множеств IP-адресов unblock
	rm -rf /opt/etc/ndm/fs.d/100-ipset.sh
	wget --no-check-certificate -O /opt/etc/ndm/fs.d/100-ipset.sh https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/100-ipset.sh
	chmod +x /opt/etc/ndm/fs.d/100-ipset.sh
	sed -i "s/hash:net/${set_type}/g" /opt/etc/ndm/fs.d/100-ipset.sh
	echo "Созданы множества IP-адресов unblock"
	
	mkdir /opt/tmp/tor
	wget --no-check-certificate -O /opt/etc/tor/torrc https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/torrc
	#sed -i "s/hash:net/${set_type}/g" /opt/etc/tor/torrc
	echo "Установлены настройки Tor"
	
	wget --no-check-certificate -O /opt/etc/shadowsocks.json https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/shadowsocks.json
	echo "Установлены настройки Shadowsocks"
	sed -i "s/ss-local/${ssredir}/g" /opt/etc/init.d/S22shadowsocks
	echo "Установлен параметр ss-redir для Shadowsocks"
	
	wget --no-check-certificate -O /opt/etc/unblocksh.txt https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/unblocksh.txt
	wget --no-check-certificate -O /opt/etc/unblocktor.txt https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/unblocktor.txt
	echo "Установлены сайты и ip адреса для обхода блокировок для обоих обходов"

	wget --no-check-certificate -O /opt/bin/unblock_ipset.sh https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/unblock_ipset.sh
	chmod +x /opt/bin/unblock_ipset.sh
	echo "Установлен скрипт для заполнения множеств unblock IP-адресами заданного списка доменов"
	
	
	wget --no-check-certificate -O /opt/bin/unblock_dnsmasq.sh https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/unblock_dnsmasq.sh
	chmod +x /opt/bin/unblock_dnsmasq.sh
	unblock_dnsmasq.sh
	echo "Установлен скрипт для формирования дополнительного конфигурационного файла dnsmasq из заданного списка доменов и его запуск"
	
	wget --no-check-certificate -O /opt/bin/unblock_update.sh https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/unblock_update.sh
	chmod +x /opt/bin/unblock_update.sh
	echo "Установлен скрипт ручного принудительного обновления системы после редактирования списка доменов"
	
	wget --no-check-certificate -O /opt/etc/init.d/S99unblock https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/S99unblock
	chmod +x /opt/etc/init.d/S99unblock
	#sed -i "s/hash:net/${set_type}/g" /opt/etc/init.d/S99unblock
	#sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/init.d/S99unblock
	echo "Установлен cкрипт автоматического заполнения множества unblock при загрузке маршрутизатора"
	
	wget --no-check-certificate -O /opt/etc/ndm/netfilter.d/100-redirect.sh https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/100-redirect.sh
	chmod +x /opt/etc/ndm/netfilter.d/100-redirect.sh
	sed -i "s/hash:net/${set_type}/g" /opt/etc/ndm/netfilter.d/100-redirect.sh
	sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/ndm/netfilter.d/100-redirect.sh
	echo "Установлено перенаправление пакетов с адресатами из unblock в Tor и Shadowsocks"
	
	rm -rf /opt/etc/dnsmasq.conf
	wget --no-check-certificate -O /opt/etc/dnsmasq.conf https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/dnsmasq.conf
	sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/dnsmasq.conf
	echo "Установлена настройка dnsmasq и подключение дополнительного конфигурационного файла к dnsmasq" 
	
	rm -rf /opt/etc/crontab
	wget --no-check-certificate -O /opt/etc/crontab https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/crontab
	echo "Установлено добавление задачи в cron для периодического обновления содержимого множества"
	ndmq -c 'opkg dns-override'
	ndmq -c 'system configuration save'
	echo "Перезагрузка роутера"
	ndmq -c 'system reboot'
	
	sleep 5
	
	exit 0
fi
