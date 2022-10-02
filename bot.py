#!/usr/bin/python
import asyncio
import subprocess
import os,stat
import telebot
from telebot import types
from telethon.sync import TelegramClient
import base64
import shutil
import datetime
import requests
# ЕСЛИ ВЫ ХОТИТЕ ПОДДЕРЖАТЬ РАЗРАБОТЧИКА - МОЖЕТЕ ОТПРАВИТЬ ДОНАТ НА ЛЮБУЮ СУММУ
# 2204 1201 0098 8217 КАРТА МИР
# 410017539693882 Юмани
# bc1qesjaxfad8f8azu2cp4gsvt2j9a4yshsc2swey9  Биткоин кошелёк

# ВЕРСИЯ СКРИПТА 1.3
token='MyTokenFromBotFather' # ключ апи бота
usernames=[]
usernames.append('Mylogin') # Добавляем логины телеграма для администраторирования бота. Строчек может быть несколько
# следующие две строки заполняются с сайта https://my.telegram.org/apps
# вместо вас запрос будет посылать бот, оттуда и будут запрашиваться ключи
appapiid='myapiid'
appapihash='myiphash'

# следующие настройки могут быть оставлены по умолчанию, но можно будет что-то поменять
routerip='192.168.1.1' # ip роутера
localportsh='1082' # локальный порт для shadowsocks
dnsporttor='9053' # чтобы onion сайты открывался через любой браузер - любой открытый порт
localporttor='9141' # локальный порт для тор
dnsovertlsport='40500' # можно посмотреть номер порта командой "cat /tmp/ndnproxymain.stat"
dnsoverhttpsport='40508' # можно посмотреть номер порта командой "cat /tmp/ndnproxymain.stat"




# Начало работы программы

bot=telebot.TeleBot(token)
level=0
bypass=-1
sid="0"
@bot.message_handler(commands=['start'])
def start(message):
    if message.from_user.username not in usernames:
        bot.send_message(message.chat.id, 'Вы не являетесь автором канала')
        return
    markup=types.ReplyKeyboardMarkup(resize_keyboard=True)
    item1=types.KeyboardButton("Установка и удаление")
    item2 = types.KeyboardButton("Списки обхода")
    markup.add(item1,item2)
    bot.send_message(message.chat.id,'Добро пожаловать в меню!',reply_markup=markup)


@bot.message_handler(content_types=['text'])
def bot_message(message):
    try:
        main = types.ReplyKeyboardMarkup(resize_keyboard=True)
        m1 = types.KeyboardButton("Установка и удаление")
        m2 = types.KeyboardButton("Списки обхода")
        main.add(m1, m2)
        if message.from_user.username not in usernames:
            bot.send_message(message.chat.id, 'Вы не являетесь автором канала')
            return
        if message.chat.type=='private':
            global level,bypass

            if (message.text == 'Назад'):
                bot.send_message(message.chat.id, 'Добро пожаловать в меню!', reply_markup=main)
                level=0
                bypass =-1
                return
            if level == 1:
                # значит это список обхода блокировок
                dirname = '/opt/etc/unblock/'
                dirfiles = os.listdir(dirname)

                for fln in dirfiles:
                    if fln == message.text+'.txt':
                        markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                        item1 = types.KeyboardButton("Показать список")
                        item2 = types.KeyboardButton("Добавить в список")
                        item3 = types.KeyboardButton("Удалить из списка")
                        back = types.KeyboardButton("Назад")
                        markup.row(item1, item2, item3)
                        markup.row(back)
                        level = 2
                        bypass = message.text
                        bot.send_message(message.chat.id, "Меню " + bypass, reply_markup=markup)
                        return

                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                back = types.KeyboardButton("Назад")
                markup.add(back)
                bot.send_message(message.chat.id, "Не найден", reply_markup=markup)
                return

            if level==2 and message.text=="Показать список":
                f=open('/opt/etc/unblock/'+bypass+'.txt')
                flag=True
                s=''
                sites=[]
                for l in f:
                    sites.append(l)
                    flag=False
                if flag:
                    s='Список пуст'
                f.close()
                sites.sort()
                if not(flag):
                    for l in sites:
                        s=str(s)+'\n'+l.replace("\n","")

                bot.send_message(message.chat.id, s)
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Показать список")
                item2 = types.KeyboardButton("Добавить в список")
                item3 = types.KeyboardButton("Удалить из списка")
                back = types.KeyboardButton("Назад")
                markup.row(item1, item2, item3)
                markup.row(back)
                bot.send_message(message.chat.id, "Меню " + bypass, reply_markup=markup)
                return

            if level == 2 and message.text == "Добавить в список":
                bot.send_message(message.chat.id,
                                 "Введите имя сайта или домена для разблокировки, либо воспользуйтесь меню для других действий")
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Добавить обход блокировок соцсетей")
                back = types.KeyboardButton("Назад")
                markup.add(item1, back)
                level = 3
                bot.send_message(message.chat.id, "Меню " + bypass, reply_markup=markup)
                return

            if level == 2 and message.text == "Удалить из списка":
                bot.send_message(message.chat.id,
                                 "Введите имя сайта или домена для удаления из листа разблокировки, либо возвратитесь в главное меню")
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                back = types.KeyboardButton("Назад")
                markup.add(back)
                level = 4
                bot.send_message(message.chat.id, "Меню " + bypass, reply_markup=markup)
                return

            if level == 3:
                f = open('/opt/etc/unblock/' + bypass + '.txt')
                mylist = set()
                k = len(mylist)
                for l in f:
                    mylist.add(l.replace('\n', ''))
                f.close()
                if (message.text == "Добавить обход блокировок соцсетей"):
                    url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/socialnet.txt"
                    s = requests.get(url).text
                    lst = s.split('\n')
                    for l in lst:
                        if len(l) > 1:
                            mylist.add(l.replace('\n', ''))
                else:
                    if len(message.text) > 1:
                        mas=message.text.split('\n')
                        for site in mas:
                            mylist.add(site)
                sortlist = []
                for l in mylist:
                    sortlist.append(l)
                sortlist.sort()
                f = open('/opt/etc/unblock/' + bypass + '.txt', 'w')
                for l in sortlist:
                    f.write(l + '\n')
                f.close()
                if (k != len(sortlist)):
                    bot.send_message(message.chat.id, "Успешно добавлено")
                else:
                    bot.send_message(message.chat.id, "Было добавлено ранее")
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Показать список")
                item2 = types.KeyboardButton("Добавить в список")
                item3 = types.KeyboardButton("Удалить из списка")
                back = types.KeyboardButton("Назад")
                markup.row(item1, item2, item3)
                markup.row(back)
                subprocess.call(["/opt/bin/unblock_update.sh"])
                level = 2
                bot.send_message(message.chat.id, "Меню " + bypass, reply_markup=markup)
                return

            if level == 4:
                f = open('/opt/etc/unblock/' + bypass + '.txt')
                mylist = set()
                k = len(mylist)
                for l in f:
                    mylist.add(l.replace('\n', ''))
                f.close()
                mas=message.text.split('\n')
                for site in mas:
                    mylist.discard(site)
                f = open('/opt/etc/unblock/' + bypass + '.txt', 'w')
                for l in mylist:
                    f.write(l + '\n')
                f.close()
                if (k != len(mylist)):
                    bot.send_message(message.chat.id, "Успешно удалено")
                else:
                    bot.send_message(message.chat.id, "Не найдено в списке")
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Показать список")
                item2 = types.KeyboardButton("Добавить в список")
                item3 = types.KeyboardButton("Удалить из списка")
                back = types.KeyboardButton("Назад")
                markup.row(item1, item2, item3)
                markup.row(back)
                level = 2
                subprocess.call(["/opt/bin/unblock_update.sh"])
                bot.send_message(message.chat.id, "Меню " + bypass, reply_markup=markup)
                return
            if level == 5:
                shadowsocks(message.text)
                subprocess.call(["/opt/etc/init.d/S22shadowsocks", "restart"])
                level=0
                bot.send_message(message.chat.id, 'Успешно обновлено', reply_markup=main)
                return
            if level == 6:
                tormanually(message.text)
                subprocess.call(["/opt/etc/init.d/S35tor", "restart"])
                level=0
                bot.send_message(message.chat.id, 'Успешно обновлено', reply_markup=main)
                return
            if level == 7:
                global sid
                mydata={'sid':sid,'answer':message.text,'mark':'Y'};
                req = requests.post('https://hi-l.im/web.php', data = mydata)
                soup = BeautifulSoup(req.text, 'html.parser')
                try:
                    mykey=soup.find(attrs={"id": "myInput"})["value"]
                    shadowsocks(mykey)
                    subprocess.call(["/opt/etc/init.d/S22shadowsocks", "restart"])
                    level=0
                    bot.send_message(message.chat.id, 'Успешно обновлено', reply_markup=main)
                except Exception as err:
                    level=0
                    bot.send_message(message.chat.id, 'Ошибка ответа. Попробуйте ещё раз', reply_markup=main)
                return
            if (message.text == 'Установка и удаление'):
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Установка \ переустановка")
                item2 = types.KeyboardButton("Удаление")
                item3 = types.KeyboardButton("Переустановить ТОР")
                item4 = types.KeyboardButton("Переустановить Shadowsocks")
                item5 = types.KeyboardButton("Переустановить ТОР вручную")
                item6 = types.KeyboardButton("Shadowsocks вручную")
                item7 = types.KeyboardButton("Shadowsocks через сайт")

                back = types.KeyboardButton("Назад")
                markup.row(item1, item2)
                markup.row(item3, item4)
                markup.row(item5)
                markup.row(item6,item7)
                markup.row(back)
                bot.send_message(message.chat.id, 'Установка и удаление', reply_markup=markup)
                return
            if (message.text == 'Переустановить ТОР'):
                tor()
                subprocess.call(["/opt/etc/init.d/S35tor", "restart"])

                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Установка \ переустановка")
                item2 = types.KeyboardButton("Удаление")
                item3 = types.KeyboardButton("Переустановить ТОР")
                item4 = types.KeyboardButton("Переустановить Shadowsocks")
                item5 = types.KeyboardButton("Переустановить ТОР вручную")
                item6 = types.KeyboardButton("Shadowsocks вручную")
                item7 = types.KeyboardButton("Shadowsocks через сайт")

                back = types.KeyboardButton("Назад")
                markup.row(item1, item2)
                markup.row(item3, item4)
                markup.row(item5)
                markup.row(item6,item7)
                markup.row(back)
                bot.send_message(message.chat.id, 'Установка и удаление', reply_markup=markup)
                return
            if (message.text == 'Переустановить Shadowsocks'):
                shadowsocks()
                subprocess.call(["/opt/etc/init.d/S22shadowsocks", "restart"])
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Установка \ переустановка")
                item2 = types.KeyboardButton("Удаление")
                item3 = types.KeyboardButton("Переустановить ТОР")
                item4 = types.KeyboardButton("Переустановить Shadowsocks")
                item5 = types.KeyboardButton("Переустановить ТОР вручную")
                item6 = types.KeyboardButton("Shadowsocks вручную")
                item7 = types.KeyboardButton("Shadowsocks через сайт")

                back = types.KeyboardButton("Назад")
                markup.row(item1, item2)
                markup.row(item3, item4)
                markup.row(item5)
                markup.row(item6,item7)
                markup.row(back)
                bot.send_message(message.chat.id, 'Установка и удаление', reply_markup=markup)
                return
            if (message.text == 'Shadowsocks вручную'):
                bot.send_message(message.chat.id,
                                 "Скопируйте ключ сюда")
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                back = types.KeyboardButton("Назад")
                markup.add(back)
                level = 5
                bot.send_message(message.chat.id, "Меню", reply_markup=markup)
                return
            if (message.text == 'Переустановить ТОР вручную'):
                bot.send_message(message.chat.id,
                                 "Скопируйте мосты сюда. Каждая новая строка - новый мост. Мост должен начинаться с obfs4")
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                back = types.KeyboardButton("Назад")
                markup.add(back)
                level = 6
                bot.send_message(message.chat.id, "Меню", reply_markup=markup)
                return
            if (message.text == 'Shadowsocks через сайт'):
                r=requests.get("https://hi-l.im/web.php?sid=001")
                soup = BeautifulSoup(r.text, 'html.parser')
                i=0
                for link in soup.find_all('p', {"class": "lead"}):
                    i+=1
                    if (i==2):
                        bot.send_message(message.chat.id,link.text.strip())
                sid=soup.find(attrs={"name": "sid"})["value"]
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                back = types.KeyboardButton("Назад")
                markup.add(back)
                level = 7
                bot.send_message(message.chat.id, "Меню", reply_markup=markup)
                return
            if (message.text == 'Установка \ переустановка'):
                bot.send_message(message.chat.id, "Начинаем установку");
                # создаём скрипт установки
                script = '#!/bin/sh'
                script += '\nopkg update'  # Обновим opkg
                # установим пакеты
                script += '\nopkg install mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config'
                script += '\nipset create test hash:net'
                script += '\nmkdir /opt/etc/unblock/'
                f = open('/opt/etc/install.sh', 'w')
                f.write(script)
                f.close()
                os.chmod('/opt/etc/install.sh', stat.S_IXUSR)
                subprocess.call(["/opt/etc/install.sh"])
                os.remove("/opt/etc/install.sh")
                bot.send_message(message.chat.id, "Установка пакетов завершена. Продолжаем установку");
                # файл для создания множеств для обхода блокировок
                f = open('/opt/etc/ndm/fs.d/100-ipset.sh', 'w')
                f.write('#!/bin/sh\n\
                [ "$1" != "start" ] && exit 0\n\
                ipset create unblocksh hash:net -exist\n\
                ipset create unblocktor hash:net -exist\n\
                #script0\n\
                #script1\n\
                #script2\n\
                #script3\n\
                #script4\n\
                #script5\n\
                #script6\n\
                #script7\n\
                #script8\n\
                #script9\n\
                exit 0')
                f.close()
                os.chmod("/opt/etc/ndm/fs.d/100-ipset.sh", stat.S_IXUSR)

                f = open('/opt/bin/unblock_update.sh', 'w')
                f.write('#!/bin/sh\n\
                ipset flush unblocktor\n\
                ipset flush unblocksh\n\
                /opt/bin/unblock_dnsmasq.sh\n\
                /opt/etc/init.d/S56dnsmasq restart\n\
                /opt/bin/unblock_ipset.sh &')
                f.close()
                os.chmod("/opt/bin/unblock_update.sh", stat.S_IXUSR)

                f = open('/opt/etc/init.d/S99unblock', 'w')
                f.write('#!/bin/sh\n\
                [ "$1" != "start" ] && exit 0\n\
                /opt/bin/unblock_ipset.sh\n\
                python /opt/etc/bot.py &')
                f.close()
                os.chmod("/opt/etc/init.d/S99unblock", stat.S_IXUSR)

                f = open('/opt/etc/crontab')
                lines = f.readlines()
                f.close()
                newline='00 06 * * * root /opt/bin/unblock_ipset.sh';
                f = open('/opt/etc/crontab', 'w')
                isnewline=True
                for l in lines:
                    if l.replace("\n","")==newline:
                        isnewline=False
                    f.write(l.replace("\n","") + '\n')
                if isnewline:
                    f.write(newline + '\n')
                f.close()
                subprocess.call(["/opt/bin/unblock_update.sh"])
                bot.send_message(message.chat.id, "Установили изначальные скрипты");

                # получение ключа shadowsocks
                shadowsocks()
                bot.send_message(message.chat.id, "Установили ключ shadowsocks");
                f = open("/opt/etc/unblock/shadowsocks.txt", 'w')
                f.close()
                f = open('/opt/etc/init.d/S22shadowsocks', 'w')
                f.write('#!/bin/sh\n\
                \n\
                ENABLED=yes\n\
                PROCS=ss-redir\n\
                ARGS="-c /opt/etc/shadowsocks.json"\n\
                PREARGS=""\n\
                DESC=$PROCS\n\
                PATH=/opt/sbin:/opt/bin:/opt/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\n\
                \n\
                [ -z "$(which $PROCS)" ] && exit 0\n\
                \n\
                . /opt/etc/init.d/rc.func')
                f.close()

                # получение мостов tor
                tor()
                bot.send_message(message.chat.id, "Установили мосты tor");
                f = open("/opt/etc/unblock/tor.txt", 'w')
                f.close()
                url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/unblock_ipset.sh"
                s = requests.get(url).text
                s = s.replace("40500", dnsovertlsport)
                f = open("/opt/bin/unblock_ipset.sh", 'w')
                f.write(s)
                f.close()
                os.chmod('/opt/bin/unblock_ipset.sh', stat.S_IXUSR)

                url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/unblock.dnsmasq"
                s = requests.get(url).text
                s = s.replace("40500", dnsovertlsport)
                f = open("/opt/bin/unblock_dnsmasq.sh", 'w')
                f.write(s)
                f.close()
                os.chmod('/opt/bin/unblock_dnsmasq.sh', stat.S_IXUSR)

                url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/100-redirect.sh"
                s = requests.get(url).text
                s = s.replace("1082", localportsh).replace("9141", localporttor).replace("192.168.1.1", routerip)
                f = open("/opt/etc/ndm/netfilter.d/100-redirect.sh", 'w')
                f.write(s)
                f.close()
                os.chmod('/opt/etc/ndm/netfilter.d/100-redirect.sh', stat.S_IXUSR)

                url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/master/dnsmasq.conf"
                s = requests.get(url).text
                s = s.replace("40500", dnsovertlsport).replace("40508", dnsoverhttpsport).replace("192.168.1.1", routerip)
                f = open("/opt/etc/dnsmasq.conf", 'w')
                f.write(s)
                f.close()
                os.chmod('/opt/etc/dnsmasq.conf', stat.S_IXUSR)

                bot.send_message(message.chat.id, "Скачали 4 основных скрипта разблокировок");

                bot.send_message(message.chat.id, "Установка завершена. Теперь нужно немного доснастроить роутер и перейти к спискам для разблокировок",
                                 reply_markup=main)
                return
            if (message.text == 'Удаление'):
                os.remove('/opt/etc/ndm/fs.d/100-ipset.sh')
                os.remove('/opt/bin/unblock_update.sh')
                os.remove('/opt/etc/init.d/S99unblock')
                os.remove('/opt/bin/unblock_ipset.sh')
                os.remove('/opt/etc/ndm/netfilter.d/100-redirect.sh')
                os.remove('/opt/bin/unblock_dnsmasq.sh')
                shutil.rmtree('/opt/etc/unblock/')
                f = open('/opt/etc/crontab')
                lines = f.readlines()
                f.close()
                f = open('/opt/etc/crontab', 'w')
                for l in lines:
                    if l != '00 06 * * * root /opt/bin/unblock_ipset.sh':
                        f.write(l + '\n')
                f.close()
                script = '#!/bin/sh'
                script += '\nopkg update'  # Обновим opkg
                # установим пакеты
                script += '\nopkg remove  mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config'
                f = open('/opt/etc/remove.sh', 'w')
                f.write(script)
                f.close()
                os.chmod('/opt/etc/remove.sh', stat.S_IXUSR)
                subprocess.call(["/opt/etc/remove.sh"])
                os.remove("/opt/etc/remove.sh")
                bot.send_message(message.chat.id, 'Успешно удалено', reply_markup=main)
                return
            if (message.text == 'Добавление других подключений'):
                bot.send_message(message.chat.id, 'Когда-нибудь позже', reply_markup=main)
                return
            if (message.text == "Списки обхода"):
                level = 1
                dirname = '/opt/etc/unblock/'
                dirfiles = os.listdir(dirname)
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                for fln in dirfiles:
                    markup.add(fln.replace(".txt", ""))
                back = types.KeyboardButton("Назад")
                markup.add(back)
                bot.send_message(message.chat.id, "Списки обхода", reply_markup=markup)
                return
    except Exception as err:
        fl=open("/opt/etc/error.log","w")
        fl.write(str(err))
        fl.close()

def shadowsocks(key=None):
    global appapiid, appapihash,password,localportsh
    if (key is None):
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        with TelegramClient('hlvpnbot', appapiid, appapihash) as client:
            client.send_message('hlvpnbot', '🔓 Любой ключ')
        now = datetime.datetime.now().timestamp()
        k = ''
        with TelegramClient('hlvpnbot', appapiid, appapihash) as client:
            while 'ss://' not in k:
                for message1 in client.iter_messages('hlvpnbot'):
                    if now > message1.date.timestamp():

                        break
                    k = message1.text
                    if 'ss://' in k:
                        break
                continue
        key = k[k.find('ss:'):k.find('?outline')]
    encodedkey = str(key).split('//')[1].split('@')[0] + '=='
    password = str(str(base64.b64decode(encodedkey)[2:]).split(':')[1])[:-1]
    server = str(key).split('@')[1].split('/')[0].split(':')[0]
    port = str(key).split('@')[1].split('/')[0].split(':')[1]
    f = open('/opt/etc/shadowsocks.json', 'w')
    sh = '{"server": ["' + server + '"], "mode": "tcp_and_udp", "server_port": ' + str( port) + ', "password": "' + password + '", "timeout": 86400,"method": "chacha20-ietf-poly1305", "local_address": "::", "local_port": ' + str(localportsh) +', "fast_open": false,    "ipv6_first": true}'

    f.write(sh)
    f.close()
def tormanually(bridges):
    global localporttor, dnsporttor
    f = open('/opt/etc/tor/torrc', 'w')
    f.write('User root\n\
PidFile /opt/var/run/tor.pid\n\
ExcludeExitNodes {RU},{UA},{AM},{KG},{BY}\n\
StrictNodes 1\n\
TransPort 0.0.0.0:' + localporttor + '\n\
ExitRelay 0\n\
ExitPolicy reject *:*\n\
ExitPolicy reject6 *:*\n\
GeoIPFile /opt/share/tor/geoip\n\
GeoIPv6File /opt/share/tor/geoip6\n\
DataDirectory /opt/tmp/tor\n\
VirtualAddrNetwork 10.254.0.0/16\n\
DNSPort 127.0.0.1:' + dnsporttor + '\n\
AutomapHostsOnResolve 1\n\
UseBridges 1\n\
ClientTransportPlugin obfs4 exec /opt/sbin/obfs4proxy managed\n' + bridges.replace("obfs4", "Bridge obfs4"))
    f.close()


def tor():
    global appapiid, appapihash
    global localporttor, dnsporttor
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    f = open('/opt/etc/tor/torrc', 'w')
    with TelegramClient('GetBridgesBot', appapiid, appapihash) as client:
        client.send_message('GetBridgesBot', '/bridges')
    with TelegramClient('GetBridgesBot', appapiid, appapihash) as client:
        for message1 in client.iter_messages('GetBridgesBot'):
            f.write('User root\n\
PidFile /opt/var/run/tor.pid\n\
ExcludeExitNodes {RU},{UA},{AM},{KG},{BY}\n\
StrictNodes 1\n\
TransPort 0.0.0.0:' + localporttor + '\n\
ExitRelay 0\n\
ExitPolicy reject *:*\n\
ExitPolicy reject6 *:*\n\
GeoIPFile /opt/share/tor/geoip\n\
GeoIPv6File /opt/share/tor/geoip6\n\
DataDirectory /opt/tmp/tor\n\
VirtualAddrNetwork 10.254.0.0/16\n\
DNSPort 127.0.0.1:' + dnsporttor + '\n\
AutomapHostsOnResolve 1\n\
UseBridges 1\n\
ClientTransportPlugin obfs4 exec /opt/sbin/obfs4proxy managed\n' + message1.text.replace("Your bridges:\n",
                                                                                         "").replace(
                "obfs4", "Bridge obfs4"))
            f.close()
            break

#bot.polling(none_stop=True)
try:
    bot.infinity_polling()
except Exception as err:
    fl=open("/opt/etc/error.log","w")
    fl.write(str(err))
    fl.close()
