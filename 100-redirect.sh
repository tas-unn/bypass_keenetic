#!/bin/sh

# 2023. Keenetic DNS bot /  Проект: bypass_keenetic / Автор: tas_unn
# GitHub: https://github.com/tas-unn/bypass_keenetic
# Данный бот предназначен для управления обхода блокировок на роутерах Keenetic
# Демо-бот: https://t.me/keenetic_dns_bot
#
# Файл: 100-redirect.sh, Версия 2.1.9, последнее изменение: 03.05.2023, 21:10
# Доработал: NetworK (https://github.com/ziwork)

#!/bin/sh

# shellcheck disable=SC2154
[ "$type" = "ip6tables" ] && exit 0
[ "$table" != "mangle" ] && [ "$table" != "nat" ] && exit 0

ip4t() {
	if ! iptables -C "$@" &>/dev/null; then
		 iptables -A "$@" || exit 0
	fi
}

local_ip=$(ip addr | grep br0 | grep 'inet' | awk '{print $2}' | grep -Eo '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}')

for protocol in udp tcp; do
	if [ -z "$(iptables-save 2>/dev/null | grep "$protocol --dport 53 -j DNAT")" ]; then
	iptables -I PREROUTING -w -t nat -p "$protocol" --dport 53 -j DNAT --to "$local_ip"; fi
done


#if [ -z "$(iptables-save 2>/dev/null | grep "--dport 53 -j DNAT")" ]; then
#    iptables -w -t nat -I PREROUTING -p udp --dport 53 -j DNAT --to 192.168.1.1
#    iptables -w -t nat -I PREROUTING -p tcp --dport 53 -j DNAT --to 192.168.1.1
#fi

# перенаправление 53 порта для br0 на определенный IP
#if [ -z "$(iptables-save 2>/dev/null | grep "udp --dport 53 -j DNAT")" ]; then
#    iptables -w -t nat -I PREROUTING -i br0 -p udp --dport 53 -j DNAT --to 192.168.1.1
#    iptables -w -t nat -I PREROUTING -i br0 -p tcp --dport 53 -j DNAT --to 192.168.1.1
#fi

# перенаправление 53 порта для sstp на определенный IP
#if [ -z "$(iptables-save 2>/dev/null | grep "tcp --dport 53 -j DNAT")" ]; then
#    iptables -w -t nat -I PREROUTING -i sstp0 -p tcp --dport 53 -j DNAT --to 192.168.1.1
#    iptables -w -t nat -I PREROUTING -i sstp0 -p udp --dport 53 -j DNAT --to 192.168.1.1
#fi


if [ -z "$(iptables-save 2>/dev/null | grep unblocksh)" ]; then
	ipset create unblocksh hash:net -exist

	# достаточно таких правил, для работы на всех интерфейсах (br0, br1, sstp0, sstp2, etc)
	iptables -I PREROUTING -w -t nat -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
	iptables -I PREROUTING -w -t nat -p udp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082

	# если у вас другой конфиг dnsmasq, и вы слушаете только определенный ip, раскоментируйте следующие строки, поставьте свой ip
	#iptables -I PREROUTING -w -t nat -p tcp -m set --match-set unblocksh dst --dport 53 -j DNAT --to 192.168.1.1
	#iptables -I PREROUTING -w -t nat -p udp -m set --match-set unblocksh dst --dport 53 -j DNAT --to 192.168.1.1

	# если вы хотите что бы обход работал только для определнных интерфейсов, закоментируйте строки выше, и раскоментируйте эти (br0)
	#iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
	#iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
	#iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocksh dst --dport 53 -j DNAT --to 192.168.1.1
	#iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocksh dst --dport 53 -j DNAT --to 192.168.1.1

	# если вы хотите что бы обход работал только для определённых интерфейсов, закоментируйте строки выше, и раскоментируйте эти (sstp0)
	#iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
	#iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
	#iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocksh dst --dport 53 -j DNAT --to 192.168.1.1
	#iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocksh dst --dport 53 -j DNAT --to 192.168.1.1

	# если вы хотите, что бы у вас были проблемы с entware (stmb, rest api), раскоментируйте эту строку
	#iptables -A OUTPUT -t nat -p tcp -m set --match-set unblocksh dst -j REDIRECT --to-port 1082
fi


if [ -z "$(iptables-save 2>/dev/null | grep unblocktor)" ]; then
  ipset create unblocktor hash:net -exist
	iptables -I PREROUTING -w -t nat -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
	iptables -I PREROUTING -w -t nat -p udp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
	#iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
	#iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
	#iptables -A PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141

	#iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
	#iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
	#iptables -A PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocktor dst -j REDIRECT --to-port 9141
fi


if [ -z "$(iptables-save 2>/dev/null | grep unblockvmess)" ]; then
  ipset create unblockvmess hash:net -exist
	iptables -I PREROUTING -w -t nat -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
	iptables -I PREROUTING -w -t nat -p udp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810

	#iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
	#iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
	#iptables -A PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810 #в целом не имеет смысла

	#iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
	#iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810
	#iptables -A PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblockvmess dst -j REDIRECT --to-port 10810 #в целом не имеет смысла
fi


if [ -z "$(iptables-save 2>/dev/null | grep unblocktroj)" ]; then
  ipset create unblocktroj hash:net -exist
	iptables -I PREROUTING -w -t nat -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
	iptables -I PREROUTING -w -t nat -p udp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829

	#iptables -I PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
	#iptables -I PREROUTING -w -t nat -i br0 -p udp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
	#iptables -A PREROUTING -w -t nat -i br0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829 #в целом не имеет смысла

	#iptables -I PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
	#iptables -I PREROUTING -w -t nat -i sstp0 -p udp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829
	#iptables -A PREROUTING -w -t nat -i sstp0 -p tcp -m set --match-set unblocktroj dst -j REDIRECT --to-port 10829 #в целом не имеет смысла
fi


TAG="100-redirect.sh"

if ls -d /opt/etc/unblock/vpn-*.txt >/dev/null 2>&1; then
for vpn_file_name in /opt/etc/unblock/vpn*; do
# выполняется цикл поиска файлов для vpn
vpn_unblock_name=$(echo $vpn_file_name | awk -F '/' '{print $5}' | sed 's/.txt//');
unblockvpn=$(echo unblock"$vpn_unblock_name");

# проверяем есть ли подключенный линк к vpn
#vpn_type=$(echo "$unblockvpn" | awk -F '-' '{print $3}') # old version
vpn_type=$(echo "$unblockvpn" | sed 's/-/ /g' | awk '{print $NF}')
vpn_link_up=$(curl -s localhost:79/rci/show/interface/"$vpn_type"/link | tr -d '"')
if [ "$vpn_link_up" = "up" ]; then

vpn_type_lower=$(echo "$vpn_type" | tr [:upper:] [:lower:])
get_vpn_fwmark_id=$(grep "$vpn_type_lower" /opt/etc/iproute2/rt_tables | awk '{print $1}')

# проверка на особый случай, когда файл vpn с сайтами есть, подключение есть, а таблицы с fwmark под него нет
#vpn_table_id=$((1000 + 1));
if [ -n "${get_vpn_fwmark_id}" ]; then vpn_table_id=$get_vpn_fwmark_id; else break; fi
vpn_mark_id=$(echo 0xd"$vpn_table_id")

#не работает должным образом
#if [ -z '$(iptables-save 2>/dev/null | grep "$unblockvpn")' ]; then

# проверяем есть ли правила vpn для множества
if iptables-save 2>/dev/null | grep -q "$unblockvpn"; then
	vpn_rule_ok=$(echo Правила для "$unblockvpn" уже есть.)
	echo "$vpn_rule_ok"
	#logger -t "$TAG" "$vpn_rule_ok"

	else
	info_vpn_rule=$(echo ipset: "$unblockvpn", mark_id: "$vpn_mark_id")
	logger -t "$TAG" "$info_vpn_rule"

	ipset create "$unblockvpn" hash:net -exist

	# проверяем fastnat и ускорители
	fastnat=$(curl -s localhost:79/rci/show/version | grep ppe)
	software=$(curl -s localhost:79/rci/show/rc/ppe | grep software -C1  | head -1 | awk '{print $2}' | tr -d ",")
	hardware=$(curl -s localhost:79/rci/show/rc/ppe | grep hardware -C1  | head -1 | awk '{print $2}' | tr -d ",")
	if [ -z "$fastnat" ] && [ "$software" = "false" ] && [ "$hardware" = "false" ]; then
	    info=$(echo "VPN: fastnat, swnat и hwnat ВЫКЛЮЧЕНЫ, правила добавлены")
		  logger -t "$TAG" "$info"
	    # С отключеными fastnat и ускорителями
	    iptables -A PREROUTING -w -t mangle -p tcp -m set --match-set "$unblockvpn" dst -j MARK --set-mark "$vpn_mark_id"
	    iptables -A PREROUTING -w -t mangle -p udp -m set --match-set "$unblockvpn" dst -j MARK --set-mark "$vpn_mark_id"

	    # закоментируйте правила выше и раскоментируйте эти, если хотите перенаправлять трафик только с интерфейса br0
	    #iptables -I PREROUTING -w -t mangle -i br0 -p tcp -m set --match-set "$unblockvpn" dst -j MARK --set-mark "$vpn_mark_id"
	    #iptables -I PREROUTING -w -t mangle -i br0 -p udp -m set --match-set "$unblockvpn" dst -j MARK --set-mark "$vpn_mark_id"

		  # не включайте, возможны проблемы: следующее исходящее правило дает возможность использовать сайты из списка в системе entware.
	    #iptables -A OUTPUT -t mangle -p tcp -m set --match-set "$unblockvpn" dst -j MARK --set-mark "$vpn_mark_id"
	else
		  info=$(echo "VPN: fastnat, swnat и hwnat ВКЛЮЧЕНЫ, правила добавлены")
		  logger -t "$TAG" "$info"
	    # Без отключения
	    iptables -A PREROUTING -w -t mangle -m conntrack --ctstate NEW -m set --match-set "$unblockvpn" dst -j CONNMARK --set-mark "$vpn_mark_id"
	    iptables -A PREROUTING -w -t mangle -j CONNMARK --restore-mark
	fi
fi # iptables
fi # link

done
fi # check files exist

# если вы хотите использовать какое-то особенное подключение vpn, имейте ввиду unblockvpn* уже используются, используйте другое имя
#if [ -z '$(iptables-save 2>/dev/null | grep unblock-custom-vpn)' ]; then
#	ipset create unblockvpn hash:net -exist

	# С отключением fastnat и ускорителей
	#iptables -I PREROUTING -w -t mangle -p tcp -m set --match-set unblock-custom-vpn dst -j MARK --set-mark 0xd1001
	#iptables -I PREROUTING -w -t mangle -p udp -m set --match-set unblock-custom-vpn dst -j MARK --set-mark 0xd1001

	# только для интерфейса br0
	#iptables -I PREROUTING -w -t mangle -i br0 -p tcp -m set --match-set unblock-custom-vpn dst -j MARK --set-mark 0xd1001
	#iptables -I PREROUTING -w -t mangle -i br0 -p udp -m set --match-set unblock-custom-vpn dst -j MARK --set-mark 0xd1001

	# Без отключения
	#iptables -I PREROUTING -w -t mangle -m conntrack --ctstate NEW -m set --match-set unblock-custom-vpn dst -j CONNMARK --set-mark 0xd1000
	#iptables -I PREROUTING -w -t mangle -j CONNMARK --restore-mark
#fi

exit 0