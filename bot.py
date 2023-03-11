#!/usr/bin/python3

#  2023. Keenetic DNS bot /  Проект: bypass_keenetic / Автор: tas_unn
#  GitHub: https://github.com/tas-unn/bypass_keenetic
#  Данный бот предназначен для управления обхода блокировок на роутерах Keenetic
#  Демо-бот: https://t.me/keenetic_dns_bot
#
#  Файл: bot.py, Версия 2.1.2, последнее изменение: 11.03.2023, 14:22
#  Доработал: NetworK (https://github.com/ziwork)

import asyncio
import subprocess
import os
import stat
import telebot
from telebot import types
from telethon.sync import TelegramClient
from pathlib import Path
import base64
import shutil
# import datetime
import requests
import json
import bot_config as config

# ВЕРСИЯ БОТА 2.1.2

# ЕСЛИ ВЫ ХОТИТЕ ПОДДЕРЖАТЬ РАЗРАБОТЧИКА - МОЖЕТЕ ОТПРАВИТЬ ДОНАТ НА ЛЮБУЮ СУММУ
# 2204 1201 0098 8217 КАРТА МИР
# 410017539693882 Юмани
# bc1qesjaxfad8f8azu2cp4gsvt2j9a4yshsc2swey9  Биткоин кошелёк

token = config.token
appapiid = config.appapiid
appapihash = config.appapihash
usernames = config.usernames
routerip = config.routerip
localportsh = config.localportsh
localporttor = config.localporttor
localporttrojan = config.localporttrojan
localportvmess = config.localportvmess
dnsovertlsport = config.dnsovertlsport
dnsporttor = config.dnsporttor
dnsoverhttpsport = config.dnsoverhttpsport

# Начало работы программы
bot = telebot.TeleBot(token)
level = 0
bypass = -1
sid = "0"


@bot.message_handler(commands=['start'])
def start(message):
    if message.from_user.username not in usernames:
        bot.send_message(message.chat.id, 'Вы не являетесь автором канала')
        return
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
    item1 = types.KeyboardButton("Установка и удаление")
    item2 = types.KeyboardButton("Ключи и мосты")
    item3 = types.KeyboardButton("Списки обхода")
    markup.add(item1, item2, item3)
    bot.send_message(message.chat.id, 'Добро пожаловать в меню!', reply_markup=markup)


@bot.message_handler(content_types=['text'])
def bot_message(message):
    try:
        main = types.ReplyKeyboardMarkup(resize_keyboard=True)
        m1 = types.KeyboardButton("Установка и удаление")
        m2 = types.KeyboardButton("Ключи и мосты")
        m3 = types.KeyboardButton("Списки обхода")
        main.add(m1, m2, m3)
        if message.from_user.username not in usernames:
            bot.send_message(message.chat.id, 'Вы не являетесь автором канала')
            return
        if message.chat.type == 'private':
            global level, bypass

            if message.text == 'Назад':
                bot.send_message(message.chat.id, 'Добро пожаловать в меню!', reply_markup=main)
                level = 0
                bypass = -1
                return
            if level == 1:
                # значит это список обхода блокировок
                dirname = '/opt/etc/unblock/'
                dirfiles = os.listdir(dirname)

                for fln in dirfiles:
                    if fln == message.text + '.txt':
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

            if level == 2 and message.text == "Показать список":
                file = open('/opt/etc/unblock/' + bypass + '.txt')
                flag = True
                s = ''
                sites = []
                for line in file:
                    sites.append(line)
                    flag = False
                if flag:
                    s = 'Список пуст'
                file.close()
                sites.sort()
                if not flag:
                    for line in sites:
                        s = str(s) + '\n' + line.replace("\n", "")

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
                                 "Введите имя сайта или домена для разблокировки, "
                                 "либо воспользуйтесь меню для других действий")
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Добавить обход блокировок соцсетей")
                back = types.KeyboardButton("Назад")
                markup.add(item1, back)
                level = 3
                bot.send_message(message.chat.id, "Меню " + bypass, reply_markup=markup)
                return

            if level == 2 and message.text == "Удалить из списка":
                bot.send_message(message.chat.id,
                                 "Введите имя сайта или домена для удаления из листа разблокировки,"
                                 "либо возвратитесь в главное меню")
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                back = types.KeyboardButton("Назад")
                markup.add(back)
                level = 4
                bot.send_message(message.chat.id, "Меню " + bypass, reply_markup=markup)
                return

            if level == 3:
                f = open('/opt/etc/unblock/' + bypass + '.txt')
                mylist = set()
                for line in f:
                    mylist.add(line.replace('\n', ''))
                f.close()
                k = len(mylist)
                if message.text == "Добавить обход блокировок соцсетей":
                    url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/main/socialnet.txt"
                    s = requests.get(url).text
                    lst = s.split('\n')
                    for line in lst:
                        if len(line) > 1:
                            mylist.add(line.replace('\n', ''))
                else:
                    if len(message.text) > 1:
                        mas = message.text.split('\n')
                        for site in mas:
                            mylist.add(site)
                sortlist = []
                for line in mylist:
                    sortlist.append(line)
                sortlist.sort()
                f = open('/opt/etc/unblock/' + bypass + '.txt', 'w')
                for line in sortlist:
                    f.write(line + '\n')
                f.close()
                if k != len(sortlist):
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
                for line in f:
                    mylist.add(line.replace('\n', ''))
                f.close()
                k = len(mylist)
                mas = message.text.split('\n')
                for site in mas:
                    mylist.discard(site)
                f = open('/opt/etc/unblock/' + bypass + '.txt', 'w')
                for line in mylist:
                    f.write(line + '\n')
                f.close()
                if k != len(mylist):
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
                level = 0
                bot.send_message(message.chat.id, 'Успешно обновлено', reply_markup=main)
                return
            if level == 6:
                tormanually(message.text)
                subprocess.call(["/opt/etc/init.d/S35tor", "restart"])
                level = 0
                bot.send_message(message.chat.id, 'Успешно обновлено', reply_markup=main)
                return
            if level == 7:
                global sid
                mydata = {'sid': sid, 'answer': message.text, 'mark': 'Y'}
                req = requests.post('https://hi-l.im/web.php', data=mydata)
                soup = BeautifulSoup(req.text, 'html.parser')
                try:
                    mykey = soup.find(attrs={"id": "myInput"})["value"]
                    shadowsocks(mykey)
                    subprocess.call(["/opt/etc/init.d/S22shadowsocks", "restart"])
                    level = 0
                    bot.send_message(message.chat.id, 'Успешно обновлено', reply_markup=main)
                except Exception as error:
                    level = 0
                    bot.send_message(message.chat.id,
                                     'Ошибка: ' + str(error) + '. \nПопробуйте ещё раз', reply_markup=main)
                return
            if level == 8:
                # значит это ключи и мосты
                if message.text == 'Tor':
                    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                    item1 = types.KeyboardButton("Tor вручную")
                    item2 = types.KeyboardButton("Tor через telegram")
                    markup.add(item1, item2)
                    back = types.KeyboardButton("Назад")
                    markup.add(back)
                    bot.send_message(message.chat.id, 'Добро пожаловать в меню Tor!', reply_markup=markup)
                if message.text == 'Shadowsocks':
                    bot.send_message(message.chat.id, "Скопируйте ключ сюда")
                    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                    back = types.KeyboardButton("Назад")
                    markup.add(back)
                    level = 5
                    bot.send_message(message.chat.id, "Меню", reply_markup=markup)
                    return

                if message.text == 'Vmess':
                    bot.send_message(message.chat.id, "Скопируйте ключ сюда")
                    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                    back = types.KeyboardButton("Назад")
                    markup.add(back)
                    level = 9
                    bot.send_message(message.chat.id, "Меню", reply_markup=markup)
                    return

                if message.text == 'Trojan':
                    bot.send_message(message.chat.id, "Скопируйте ключ сюда")
                    markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                    back = types.KeyboardButton("Назад")
                    markup.add(back)
                    level = 10
                    bot.send_message(message.chat.id, "Меню", reply_markup=markup)
                    return
            if level == 9:
                vmess(message.text)
                subprocess.call(["/opt/etc/init.d/S24v2ray", "restart"])
                level = 0
                bot.send_message(message.chat.id, 'Успешно обновлено', reply_markup=main)
            if level == 10:
                trojan(message.text)
                subprocess.call(["/opt/etc/init.d/S22trojan", "restart"])
                level = 0
                bot.send_message(message.chat.id, 'Успешно обновлено', reply_markup=main)

            if message.text == 'Tor вручную':
                bot.send_message(message.chat.id, "Скопируйте ключ сюда")
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                back = types.KeyboardButton("Назад")
                markup.add(back)
                level = 6
                bot.send_message(message.chat.id, "Меню", reply_markup=markup)
                return

            if message.text == 'Tor через telegram':
                tor()
                subprocess.call(["/opt/etc/init.d/S35tor", "restart"])
                level = 0
                bot.send_message(message.chat.id, 'Успешно обновлено', reply_markup=main)
                return

            if message.text == 'Установка и удаление':
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Установка & переустановка")
                item2 = types.KeyboardButton("Удаление")
                back = types.KeyboardButton("Назад")
                markup.row(item1, item2)
                markup.row(back)
                bot.send_message(message.chat.id, 'Установка и удаление', reply_markup=markup)
                return
            if message.text == 'Установка & переустановка':
                bot.send_message(message.chat.id, "Начинаем установку")
                # создаём скрипт установки
                script = '#!/bin/sh'
                script += '\nopkg update'  # Обновим opkg
                # установим пакеты
                script += '\nopkg install mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config v2ray trojan'
                script += '\npip install pyTelegramBotAPI telethon pathlib'
                script += '\nmkdir -p /opt/etc/unblock/'
                f = open('/opt/etc/install.sh', 'w')
                f.write(script)
                f.close()
                os.chmod('/opt/etc/install.sh', stat.S_IRWXU)
                subprocess.call(["/opt/etc/install.sh"])
                os.remove("/opt/etc/install.sh")
                bot.send_message(message.chat.id, "Установка пакетов завершена. Продолжаем установку")

                os.chmod(r"/opt/etc/unblock/tor.txt", 0o0755)
                os.chmod(r"/opt/etc/unblock/shadowsocks.txt", 0o0755)
                os.chmod(r"/opt/etc/unblock/trojan.txt", 0o0755)
                os.chmod(r"/opt/etc/unblock/vmess.txt", 0o0755)
                os.chmod(r"/opt/etc/unblock/vpn.txt", 0o0755)

                Path('/opt/etc/unblock/tor.txt').touch()
                Path('/opt/etc/unblock/shadowsocks.txt').touch()
                Path('/opt/etc/unblock/trojan.txt').touch()
                Path('/opt/etc/unblock/vmess.txt').touch()
                Path('/opt/etc/unblock/vpn.txt').touch()
                Path.touch(mode=0o755, exist_ok=True)

                # f = open('/opt/etc/unblock/tor.txt', 'w')
                # f.close()
                # os.chmod(r"/opt/etc/unblock/tor.txt", 0o0755)
                # f = open('/opt/etc/unblock/shadowsocks.txt', 'w')
                # f.close()
                # os.chmod(r"/opt/etc/unblock/shadowsocks.txt", 0o0755)
                # f = open('/opt/etc/unblock/trojan.txt', 'w')
                # f.close()
                # os.chmod(r"/opt/etc/unblock/trojan.txt", 0o0755)
                # f = open('/opt/etc/unblock/vmess.txt', 'w')
                # f.close()
                # os.chmod(r"/opt/etc/unblock/vmess.txt", 0o0755)

                bot.send_message(message.chat.id, "Создали файлы под множества")
                # файл для создания множеств для обхода блокировок
                os.chmod(r"/opt/etc/ndm/fs.d/100-ipset.sh", 0o0755)
                f = open('/opt/etc/ndm/fs.d/100-ipset.sh', 'w')
                f.write('#!/bin/sh\n\
                [ "$1" != "start" ] && exit 0\n\
                ipset create unblocksh hash:net -exist\n\
                ipset create unblocktor hash:net -exist\n\
                ipset create unblockvmess hash:net -exist\n\
                ipset create unblocktroj hash:net -exist\n\
                ipset create unblockvpn hash:net -exist\n\
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
                os.chmod(r"/opt/etc/ndm/fs.d/100-ipset.sh", 0o0755)
                os.chmod("/opt/etc/ndm/fs.d/100-ipset.sh", stat.S_IRWXU)

                os.chmod(r"/opt/bin/unblock_update.sh", 0o0755)
                f = open('/opt/bin/unblock_update.sh', 'w')
                f.write('#!/bin/sh\n\
                ipset flush unblocktor\n\
                ipset flush unblocksh\n\
                ipset flush unblockvmess\n\
                ipset flush unblocktroj\n\
                ipset flush unblockvpn\n\
                /opt/bin/unblock_dnsmasq.sh\n\
                /opt/etc/init.d/S56dnsmasq restart\n\
                /opt/bin/unblock_ipset.sh &')
                f.close()
                os.chmod(r"/opt/bin/unblock_update.sh", 0o0755)
                os.chmod("/opt/bin/unblock_update.sh", stat.S_IRWXU)

                os.chmod(r"/opt/etc/init.d/S99unblock", 0o0755)
                f = open('/opt/etc/init.d/S99unblock', 'w')
                f.write('#!/bin/sh\n\
                [ "$1" != "start" ] && exit 0\n\
                /opt/bin/unblock_ipset.sh\n\
                python3 /opt/etc/bot.py &')
                f.close()
                os.chmod(r"/opt/etc/init.d/S99unblock", 0o0755)
                os.chmod("/opt/etc/init.d/S99unblock", stat.S_IRWXU)

                os.chmod(r"/opt/etc/crontab", 0o0755)
                f = open('/opt/etc/crontab')
                lines = f.readlines()
                f.close()
                newline = '00 06 * * * root /opt/bin/unblock_ipset.sh'
                f = open('/opt/etc/crontab', 'w')
                isnewline = True
                for line in lines:
                    if line.replace("\n", "") == newline:
                        isnewline = False
                    f.write(line.replace("\n", "") + '\n')
                if isnewline:
                    f.write(newline + '\n')
                f.close()
                subprocess.call(["/opt/bin/unblock_update.sh"])
                bot.send_message(message.chat.id, "Установили изначальные скрипты")

                # получение мостов tor
                tor()
                bot.send_message(message.chat.id, "Установили мосты tor")

                os.chmod(r"/opt/etc/unblock/tor.txt", 0o0755)
                f = open("/opt/etc/unblock/tor.txt", 'w')
                f.close()

                os.chmod(r"/opt/bin/unblock_ipset.sh", 0o0755)
                url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/main/unblock_ipset.sh"
                s = requests.get(url).text
                s = s.replace("40500", dnsovertlsport)
                f = open("/opt/bin/unblock_ipset.sh", 'w')
                f.write(s)
                f.close()
                os.chmod(r"/opt/bin/unblock_ipset.sh", 0o0755)
                os.chmod('/opt/bin/unblock_ipset.sh', stat.S_IRWXU)

                os.chmod(r"/opt/bin/unblock_dnsmasq.sh", 0o0755)
                os.chmod(r"/opt/bin/unblock_dnsmasq.sh", 0o0755)
                url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/main/unblock.dnsmasq"
                s = requests.get(url).text
                s = s.replace("40500", dnsovertlsport)
                f = open("/opt/bin/unblock_dnsmasq.sh", 'w')
                f.write(s)
                f.close()
                os.chmod(r"/opt/bin/unblock_dnsmasq.sh", 0o0755)
                os.chmod('/opt/bin/unblock_dnsmasq.sh', stat.S_IRWXU)

                os.chmod(r"/opt/etc/ndm/netfilter.d/100-redirect.sh", 0o0755)
                url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/main/100-redirect.sh"
                s = requests.get(url).text
                s = s.replace("1082", localportsh).replace("9141", localporttor)
                s = s.replace("10810", localportvmess).replace("10829", localporttrojan)
                s = s.replace("192.168.1.1", routerip)
                f = open("/opt/etc/ndm/netfilter.d/100-redirect.sh", 'w')
                f.write(s)
                f.close()
                os.chmod(r"/opt/etc/ndm/netfilter.d/100-redirect.sh", 0o0755)
                os.chmod('/opt/etc/ndm/netfilter.d/100-redirect.sh', stat.S_IRWXU)

                os.chmod(r"/opt/etc/ndm/ifstatechanged.d/100-unblock-vpn", 0o0755)
                url = "https://raw.githubusercontent.com/ziwork/bypass_keenetic/main/100-unblock-vpn.sh"
                s = requests.get(url).text
                f = open("/opt/etc/ndm/ifstatechanged.d/100-unblock-vpn", 'w')
                f.write(s)
                f.close()
                os.chmod(r"/opt/etc/ndm/ifstatechanged.d/100-unblock-vpn", 0o0755)
                os.chmod('/opt/etc/ndm/ifstatechanged.d/100-unblock-vpn', stat.S_IRWXU)

                os.chmod(r"/opt/etc/dnsmasq.conf", 0o0755)
                url = "https://raw.githubusercontent.com/tas-unn/bypass_keenetic/main/dnsmasq.conf"
                s = requests.get(url).text
                s = s.replace("40500", dnsovertlsport).replace("40508", dnsoverhttpsport)
                s = s.replace("192.168.1.1", routerip)
                f = open("/opt/etc/dnsmasq.conf", 'w')
                f.write(s)
                f.close()
                os.chmod(r"/opt/etc/dnsmasq.conf", 0o0755)
                os.chmod('/opt/etc/dnsmasq.conf', stat.S_IRWXU)

                bot.send_message(message.chat.id, "Скачали 4 основных скрипта разблокировок")

                bot.send_message(message.chat.id,
                                 "Установка завершена. Теперь нужно немного донастроить роутер и перейти к"
                                 "спискам для разблокировок. "
                                 "Ключи для Vmess, Shadowsocks и Trojan необходимо установить вручную",
                                 reply_markup=main)
                return
            if message.text == 'Удаление':
                os.remove('/opt/etc/ndm/fs.d/100-ipset.sh')
                os.remove('/opt/bin/unblock_update.sh')
                os.remove('/opt/etc/init.d/S99unblock')
                os.remove('/opt/bin/unblock_ipset.sh')
                os.remove('/opt/etc/ndm/netfilter.d/100-redirect.sh')
                os.remove('/opt/etc/ndm/ifstatechanged.d/100-unblock-vpn.sh')
                os.remove('/opt/bin/unblock_dnsmasq.sh')
                shutil.rmtree('/opt/etc/unblock/')
                f = open('/opt/etc/crontab')
                lines = f.readlines()
                f.close()
                f = open('/opt/etc/crontab', 'w')
                for line in lines:
                    if line != '00 06 * * * root /opt/bin/unblock_ipset.sh':
                        f.write(line + '\n')
                f.close()
                script = '#!/bin/sh'
                script += '\nopkg update'  # Обновим opkg
                # установим пакеты
                script += '\nopkg remove  mc tor tor-geoip bind-dig cron dnsmasq-full ipset iptables obfs4 shadowsocks-libev-ss-redir shadowsocks-libev-config'
                f = open('/opt/etc/remove.sh', 'w')
                f.write(script)
                f.close()
                os.chmod('/opt/etc/remove.sh', stat.S_IRWXU)
                subprocess.call(["/opt/etc/remove.sh"])
                os.remove("/opt/etc/remove.sh")
                bot.send_message(message.chat.id, 'Успешно удалено', reply_markup=main)
                return
            if message.text == "Списки обхода":
                level = 1
                dirname = '/opt/etc/unblock/'
                dirfiles = os.listdir(dirname)
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                markuplist = []
                for fln in dirfiles:
                    # markup.add(fln.replace(".txt", ""))
                    btn = fln.replace(".txt", "")
                    markuplist.append(btn)
                markup.add(*markuplist)
                back = types.KeyboardButton("Назад")
                markup.add(back)
                bot.send_message(message.chat.id, "Списки обхода", reply_markup=markup)
                return
            if message.text == "Ключи и мосты":
                level = 8
                markup = types.ReplyKeyboardMarkup(resize_keyboard=True)
                item1 = types.KeyboardButton("Shadowsocks")
                item2 = types.KeyboardButton("Tor")
                item3 = types.KeyboardButton("Vmess")
                item4 = types.KeyboardButton("Trojan")
                markup.add(item1, item2, item3, item4)
                back = types.KeyboardButton("Назад")
                markup.add(back)
                bot.send_message(message.chat.id, "Ключи и мосты", reply_markup=markup)
                return
    except Exception as error:
        file = open("/opt/etc/error.log", "w")
        file.write(str(error))
        file.close()
        os.chmod(r"/opt/etc/error.log", 0o0755)


def vmess(key):
    # global appapiid, appapihash, password, localportvmess
    encodedkey = key[8:]
    s = base64.b64decode(encodedkey).decode('utf8').replace("'", '"')
    jsondata = json.loads(s)
    f = open('/opt/etc/v2ray/config.json', 'w')
    sh = '{"log":{"access":"","error":"","loglevel":"none"},"inbounds":[{"port":' \
         + str(localportvmess) + \
         ',"listen":"::","protocol":"dokodemo-door","settings":{"network":"tcp","followRedirect":true}}],' \
         '"outbounds":[{"tag":"proxy","protocol":"vmess","settings":{"vnext":[{"address":"' \
         + str(jsondata["add"]) + '","port":' + str(jsondata["port"]) + ',"users":[{"id":"' \
         + str(jsondata["id"]) + '","alterId":"' + str(jsondata["aid"]) + \
         '","email":"t@t.tt","security":"auto"}]}]},"streamSettings":{"network":"ws","security":"tls","tlsSettings":{' \
         '"allowInsecure":true,"serverName":"' \
         + str(jsondata["add"]) + '"},"wsSettings":{"path":"/' + str(jsondata["ps"]) + \
         '","headers":{"Host":"' + str(jsondata["host"]) + \
         '"}},"tls":"tls"},"mux":{"enabled":false,"concurrency":-1}}],"routing":{"domainStrategy":"IPIfNonMatch",' \
         '"rules":[{"type":"field","port":"0-65535","outboundTag":"proxy","enabled":true}]}}'

    f.write(sh)
    f.close()


def trojan(key):
    # global appapiid, appapihash, password, localportvmess
    key = key.split('//')[1]
    pw = key.split('@')[0]
    key = key.replace(pw + "@", "", 1)
    host = key.split(':')[0]
    key = key.replace(host + ":", "", 1)
    port = key.split('?')[0]
    f = open('/opt/etc/trojan/config.json', 'w')
    sh = '{"run_type":"nat","local_addr":"::","local_port":' \
         + str(localporttrojan) + ',"remote_addr":"' + host + '","remote_port":' + port + \
         ',"password":["' + pw + '"],"ssl":{"verify":false,"verify_hostname":false}}'

    f.write(sh)
    f.close()


def shadowsocks(key=None):
    # global appapiid, appapihash, password, localportsh
    encodedkey = str(key).split('//')[1].split('@')[0] + '=='
    password = str(str(base64.b64decode(encodedkey)[2:]).split(':')[1])[:-1]
    server = str(key).split('@')[1].split('/')[0].split(':')[0]
    port = str(key).split('@')[1].split('/')[0].split(':')[1].split('#')[0]
    method = str(str(base64.b64decode(encodedkey)).split(':')[0])[2:]
    f = open('/opt/etc/shadowsocks.json', 'w')
    sh = '{"server": ["' + server + '"], "mode": "tcp_and_udp", "server_port": ' \
         + str(port) + ', "password": "' + password + \
         '", "timeout": 86400,"method": "' + method + \
         '", "local_address": "::", "local_port": ' \
         + str(localportsh) + ', "fast_open": false,    "ipv6_first": true}'

    f.write(sh)
    f.close()


def tormanually(bridges):
    # global localporttor, dnsporttor
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
    # global appapiid, appapihash
    # global localporttor, dnsporttor
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
ClientTransportPlugin obfs4 exec /opt/sbin/obfs4proxy managed\n'
                    + message1.text.replace("Your bridges:\n", "").replace("obfs4", "Bridge obfs4"))
            f.close()
            break


# bot.polling(none_stop=True)
try:
    bot.infinity_polling()
except Exception as err:
    fl = open("/opt/etc/error.log", "w")
    fl.write(str(err))
    fl.close()
