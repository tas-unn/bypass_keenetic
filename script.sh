#!/bin/sh

# 2023. Keenetic DNS bot /  Проект: bypass_keenetic / Автор: tas_unn
# GitHub: https://github.com/tas-unn/bypass_keenetic
# Данный бот предназначен для управления обхода блокировок на роутерах Keenetic
# Демо-бот: https://t.me/keenetic_dns_bot
#
# Файл: script.sh, Версия 2.1.1, последнее изменение: 29.03.2023, 16:02
# Доработал: NetworK (https://github.com/ziwork)

# оригинальный репозиторий
#repo="tas-unn"

# FORK by NetworK
repo="ziwork"

if [ "$1" = "remove" ]; then
	echo "Начинаем удаление"
	# opkg remove curl mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config
	opkg remove mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config python3 python3-pip v2ray trojan
	echo "Пакеты удалены, удаляем папки, файлы и настройки"
	ipset flush unblocktor
  ipset flush unblocksh
  ipset flush unblockvmess
  ipset flush unblocktroj
  ipset flush unblockvpn
	ipset flush testset
	chmod 777 /opt/root/get-pip.py || rm -Rfv /opt/root/get-pip.py
	chmod 777 /opt/etc/crontab || rm -Rfv /opt/etc/crontab
	chmod 777 /opt/etc/init.d/S22shadowsocks || rm -Rfv /opt/etc/init.d/S22shadowsocks
	chmod 777 /opt/etc/init.d/S22trojan || rm -Rfv /opt/etc/init.d/S22trojan
	chmod 777 /opt/etc/init.d/S24v2ray || rm -Rfv /opt/etc/init.d/S24v2ray
	chmod 777 /opt/etc/init.d/S35tor || rm -Rfv /opt/etc/init.d/S35tor
	chmod 777 /opt/etc/init.d/S56dnsmasq || rm -Rfv /opt/etc/init.d/S56dnsmasq
	chmod 777 /opt/etc/init.d/S99unblock || rm -Rfv /opt/etc/init.d/S99unblock
	chmod 777 /opt/etc/ndm/netfilter.d/100-redirect.sh || rm -rfv /opt/etc/ndm/netfilter.d/100-redirect.sh
	chmod 777 /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh || rm -rfv /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh
  chmod 777 /opt/etc/nmd/fs.d/100-ipset.sh || rm -rfv /opt/etc/nmd/fs.d/100-ipset.sh
  chmod 777 /opt/bin/unblock_dnsmasq.sh || rm -rfv /opt/bin/unblock_dnsmasq.sh
  chmod 777 /opt/bin/unblock_update.sh || rm -rfv /opt/bin/unblock_update.sh
	chmod 777 /opt/bin/unblock_ipset.sh || rm -rfv /opt/bin/unblock_ipset.sh
	chmod 777 /opt/etc/unblock.dnsmasq || rm -rfv /opt/etc/unblock.dnsmasq
	chmod 777 /opt/etc/dnsmasq.conf || rm -rfv /opt/etc/dnsmasq.conf
	chmod 777 /opt/tmp/tor || rm -Rfv /opt/tmp/tor
  # chmod 777 /opt/etc/unblock || rm -Rfv /opt/etc/unblock
  chmod 777 /opt/etc/tor || rm -Rfv /opt/etc/tor
	chmod 777 /opt/etc/v2ray || rm -Rfv /opt/etc/v2ray
	chmod 777 /opt/etc/trojan || rm -Rfv /opt/etc/trojan
	echo "Созданные папки, файлы и настройки удалены"
	echo "Отключаем opkg dns-override"
  ndmc -c 'no opkg dns-override'
	sleep 3
	echo "Сохраняем конфигурацию на роутере"
  ndmc -c 'system configuration save'
	sleep 3
	echo "Перезагрузка роутера"
	sleep 3
  ndmc -c 'system reboot'
  exit 0
fi

if [ "$1" = "install" ]; then
	echo "Начинаем установку"
	opkg update
	# opkg install curl mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config
	opkg install curl mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config python3 python3-pip v2ray trojan
	curl -O https://bootstrap.pypa.io/get-pip.py
	sleep 3
	python get-pip.py
	pip install pyTelegramBotAPI
	pip install telethon
	pip install pathlib
	#pip install --upgrade pip
	#pip install pytelegrambotapi
	#pip install paramiko
	echo "Установили пакеты"
	ipset flush unblocktor
  ipset flush unblocksh
  ipset flush unblockvmess
  ipset flush unblocktroj
	ipset flush testset
	ipset flush unblockvpn
	# есть поддержка множества hash:net или нет, если нет, то при этом вы потеряете возможность разблокировки по диапазону и CIDR
	set_type="hash:net"
	ipset create testset hash:net -exist > /dev/null 2>&1
	retVal=$?
	if [ $retVal -ne 0 ]; then
	  set_type="hash:ip"
	fi
	# ip роутера
	lanip=$(ip addr show br0 | grep -Po "(?<=inet ).*(?=/)" | awk '{print $1}')
	ssredir="ss-redir"
	echo "Переменные роутера найдены"
	# создания множеств IP-адресов unblock
	# rm -rf /opt/etc/ndm/fs.d/100-ipset.sh
	chmod 777 /opt/etc/nmd/fs.d/100-ipset.sh || rm -rfv /opt/etc/nmd/fs.d/100-ipset.sh
	curl -o /opt/etc/ndm/fs.d/100-ipset.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/100-ipset.sh
	chmod 1755 /opt/etc/ndm/fs.d/100-ipset.sh
	sed -i "s/hash:net/${set_type}/g" /opt/etc/ndm/fs.d/100-ipset.sh
	echo "Созданы множества IP-адресов unblock"

	chmod 777 /opt/tmp/tor || rm -Rfv /opt/tmp/tor
  chmod 777 /opt/etc/tor/torrc || rm -Rfv /opt/etc/tor/torrc
	mkdir /opt/tmp/tor
	curl -o /opt/etc/tor/torrc https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/torrc
	#sed -i "s/hash:net/${set_type}/g" /opt/etc/tor/torrc
	echo "Установлены настройки Tor"

	chmod 777 /opt/etc/shadowsocks.json || rm -Rfv /opt/etc/shadowsocks.json
	chmod 777 /opt/etc/init.d/S22shadowsocks || rm -Rfv /opt/etc/init.d/S22shadowsocks
	curl -o /opt/etc/shadowsocks.json https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/shadowsocks.json
	echo "Установлены настройки Shadowsocks"
	sed -i "s/ss-local/${ssredir}/g" /opt/etc/init.d/S22shadowsocks
	chmod 0755 /opt/etc/shadowsocks.json || chmod 1755 /opt/etc/init.d/S22shadowsocks
	echo "Установлен параметр ss-redir для Shadowsocks"

	#chmod 777 /opt/etc/v2ray/config.json | rm -Rfv /opt/etc/v2ray/config.json
	#curl -o /opt/etc/v2ray/config.json https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/vmessconfig.json

	#chmod 777 /opt/etc/trojan/config.json | rm -Rfv /opt/etc/trojan/config.json
	#curl -o /opt/etc/trojan/config.json https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/trojanconfig.json

	touch /opt/etc/unblock/shadowsocks.txt || chmod 0755 /opt/etc/unblock/shadowsocks.txt
	touch /opt/etc/unblock/tor.txt  || chmod 0755 /opt/etc/unblock/tor.txt
	touch /opt/etc/unblock/trojan.txt  || chmod 0755 /opt/etc/unblock/trojan.txt
	touch /opt/etc/unblock/vmess.txt  || chmod 0755 /opt/etc/unblock/vmess.txt
	touch /opt/etc/unblock/vpn.txt  || chmod 0755 /opt/etc/unblock/vpn.txt
	echo "Созданы файлы под сайты и ip-адреса для обхода блокировок для SS, Tor, Trojan и v2ray, VPN"

	chmod 777 /opt/bin/unblock_ipset.sh || rm -rfv /opt/bin/unblock_ipset.sh
	curl -o /opt/bin/unblock_ipset.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/unblock_ipset.sh
	chmod 1755 /opt/bin/unblock_ipset.sh
	echo "Установлен скрипт для заполнения множеств unblock IP-адресами заданного списка доменов"

  chmod 777 /opt/bin/unblock_dnsmasq.sh || rm -rfv /opt/bin/unblock_dnsmasq.sh
	curl -o /opt/bin/unblock_dnsmasq.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/unblock_dnsmasq
	chmod 1755 /opt/bin/unblock_dnsmasq.sh
	unblock_dnsmasq.sh
	echo "Установлен скрипт для формирования дополнительного конфигурационного файла dnsmasq из заданного списка доменов и его запуск"

  chmod 777 /opt/bin/unblock_update.sh || rm -rfv /opt/bin/unblock_update.sh
	curl -o /opt/bin/unblock_update.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/unblock_update.sh
	chmod 1755 /opt/bin/unblock_update.sh
	echo "Установлен скрипт ручного принудительного обновления системы после редактирования списка доменов"

	chmod 777 /opt/etc/init.d/S99unblock || rm -Rfv /opt/etc/init.d/S99unblock
	curl -o /opt/etc/init.d/S99unblock https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/S99unblock
	chmod 1755 /opt/etc/init.d/S99unblock
	#sed -i "s/hash:net/${set_type}/g" /opt/etc/init.d/S99unblock
	sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/init.d/S99unblock
	echo "Установлен cкрипт автоматического заполнения множества unblock при загрузке маршрутизатора"

	chmod 777 /opt/etc/ndm/netfilter.d/100-redirect.sh || rm -rfv /opt/etc/ndm/netfilter.d/100-redirect.sh
	curl -o /opt/etc/ndm/netfilter.d/100-redirect.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/100-redirect.sh
	chmod 1755 /opt/etc/ndm/netfilter.d/100-redirect.sh
	sed -i "s/hash:net/${set_type}/g" /opt/etc/ndm/netfilter.d/100-redirect.sh
	sed -i "s/${lanip}/${lanip}/g" /opt/etc/ndm/netfilter.d/100-redirect.sh
	echo "Установлено перенаправление пакетов с адресатами из unblock в: Tor, Shadowsocks, VPN, Trojan, v2ray"

  chmod 777 /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh || rm -rfv /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh
	curl -o /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/100-unblock-vpn.sh
	chmod 1755 /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh
	echo "Установлен хук проверки поднятия и остановки VPN"

	#rm -rf /opt/etc/dnsmasq.conf
	chmod 777 /opt/etc/dnsmasq.conf || rm -rfv /opt/etc/dnsmasq.conf
	curl -o /opt/etc/dnsmasq.conf https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/dnsmasq.conf
	sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/dnsmasq.conf
	chmod 755 /opt/etc/dnsmasq.conf
	echo "Установлена настройка dnsmasq и подключение дополнительного конфигурационного файла к dnsmasq"

	#rm -rf /opt/etc/crontab
	chmod 777 /opt/etc/crontab || rm -Rfv /opt/etc/crontab
	curl -o /opt/etc/crontab https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/crontab
	chmod 755 /opt/etc/crontab
	echo "Установлено добавление задачи в cron для периодического обновления содержимого множества"
	ndmc -c 'opkg dns-override'
	sleep 3
	ndmc -c 'system configuration save'
	sleep 3
	echo "Перезагрузка роутера"
	ndmc -c 'system reboot'

	sleep 5

	exit 0
fi

if [ "$1" = "reinstall" ]; then
	echo "Начинаем переустановку"
	# opkg remove curl mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config
	opkg update
	echo "В разработке"
  exit 0
fi


if [ "$1" = "update" ]; then
	echo "Начинаем обновление"
	opkg update > /dev/null 2>&1
	echo "Пакеты обновлены"

	/opt/etc/init.d/S22shadowsocks stop
	/opt/etc/init.d/S24v2ray stop
	/opt/etc/init.d/S22trojan stop
	/opt/etc/init.d/S35tor stop
	echo "Сервисы остановлены"

  now=$(date +"%Y.%m.%d.%H-%M")
	mkdir /opt/root/backup-"${now}"
	mv /opt/bin/unblock_*.sh /opt/root/backup-"${now}"/*
	mv /opt/etc/dnsmasq.conf /opt/root/backup-"${now}"/*
	mv /opt/etc/ndm/fs.d/100-ipset.sh /opt/root/backup-"${now}"/*
	mv /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh /opt/root/backup-"${now}"/*
	mv /opt/etc/ndm/netfilter.d/100-redirect.sh /opt/root/backup-"${now}"/*
	mv /opt/etc/bot.py /opt/root/backup-"${now}"/*
	echo "Бэкап создан"

	curl -s -o /opt/etc/ndm/fs.d/100-ipset.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/100-ipset.sh
	chmod 755 /opt/etc/ndm/fs.d/100-ipset.sh || chmod +x /opt/etc/ndm/fs.d/100-ipset.sh
	curl -s -o /opt/etc/ndm/netfilter.d/100-redirect.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/100-redirect.sh
	chmod 755 /opt/etc/ndm/netfilter.d/100-redirect.sh || chmod +x /opt/etc/ndm/netfilter.d/100-redirect.sh
  curl -s -o /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/100-unblock-vpn.sh
  chmod 755 /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh || chmod +x /opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh

	curl -s -o /opt/bin/unblock_ipset.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/unblock_ipset.sh
	curl -s -o /opt/bin/unblock_dnsmasq.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/unblock_dnsmasq
	curl -s -o /opt/bin/unblock_update.sh https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/unblock_update.sh
	chmod 755 /opt/bin/unblock_*.sh || chmod +x /opt/bin/unblock_*.sh

	curl -s -o /opt/etc/dnsmasq.conf https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/dnsmasq.conf
  chmod 755 /opt/etc/dnsmasq.conf
  lanip=$(ip addr show br0 | grep -Po "(?<=inet ).*(?=/)" | awk '{print $1}')
  sed -i "s/192.168.1.1/${lanip}/g" /opt/etc/dnsmasq.conf

  curl -s -o /opt/etc/bot.py https://raw.githubusercontent.com/${repo}/bypass_keenetic/main/bot.py
  chmod 755 /opt/etc/bot.py
  echo "Обновления скачены, права настроены"

  /opt/etc/init.d/S56dnsmasq restart &
  /opt/etc/init.d/S22shadowsocks start &
	/opt/etc/init.d/S24v2ray start &
	/opt/etc/init.d/S22trojan start &
	/opt/etc/init.d/S35tor start &

  echo "Обновление выполнено. Сервисы перезапущены. Сейчас будет перезапущен бот."
  sleep 2
  # shellcheck disable=SC2009
  # bot=$(ps | grep bot.py | awk '{print $1}' | head -1)
  bot_pid=$(ps | grep bot.py | awk '{print $1}')
  for bot in ${bot_pid}; do kill "${bot}"; done
  sleep 3
  python3 /opt/etc/bot.py &
  exit 0
fi

if [ -n "$1" ]; then
  echo not found "$1".
  echo "install    - use for install all needs for work"
  echo "remove     - use for remove all files script"
  echo "update     - use for get update files"
  echo "reinstall  - use for reinstall all files script"
else
  echo "install    - use for install all needs for work"
  echo "remove     - use for remove all files script"
  echo "update     - use for get update files"
  echo "reinstall  - use for reinstall all files script"
fi