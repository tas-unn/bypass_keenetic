# bypass_keenetic
Установка обхода блокировок на роутерах Keenetic с установленной средой OpenWrt

## Как обновиться:
- opkg update
- opkg install curl python3 python3-pip mc bind-dig cron dnsmasq-full ipset iptables obfs4 tor tor-geoip shadowsocks-libev-ss-redir shadowsocks-libev-config v2ray trojan
- pip install pathlib
- mv /opt/etc/bot.py /opt/etc/bot_old.py
- curl -o /opt/etc/bot.py https://raw.githubusercontent.com/ziwork/bypass_keenetic/main/bot.py
- curl -o /opt/etc/bot_config.py https://raw.githubusercontent.com/ziwork/bypass_keenetic/main/bot_config.py
- mcedit /opt/etc/bot_config.py # внести свои данные
- Открыть бота в телеграм -> Установка -> Установка & Переустановка
- Enjoy. ([@ziwork](https://github.com/ziwork))

Полное описание:
https://habr.com/ru/post/669314/

Поддержать проект:

2204 1201 0098 8217 КАРТА МИР

410017539693882 Юмани

bc1qesjaxfad8f8azu2cp4gsvt2j9a4yshsc2swey9  Биткоин кошелёк
