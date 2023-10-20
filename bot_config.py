# ВЕРСИЯ СКРИПТА 2.2.0

token = 'MyBotFatherToken'  # ключ api бота
usernames = ['MySuperLogin']  # Ваш логин в телеграмме без @, не бота. Логин именно Вашей учетной записи в ТГ.

# следующие две строки заполняются с сайта https://my.telegram.org/apps
# вместо вас запрос будет посылать бот, оттуда и будут запрашиваться ключи
appapiid = 'myapiid'
appapihash = 'myiphash'
routerip = '192.168.1.1'  # ip роутера

# список vpn для выборочной маршрутизации
vpn_allowed="IKE|SSTP|OpenVPN|Wireguard|L2TP"

# следующие настройки могут быть оставлены по умолчанию, но можно будет что-то поменять
localportsh = '1082'  # локальный порт для shadowsocks
dnsporttor = '9053'  # чтобы onion сайты открывался через любой браузер - любой открытый порт
localporttor = '9141'  # локальный порт для тор
localportvmess = '10810'  # локальный порт для vmess
localporttrojan = '10829'  # локальный порт для trojan
dnsovertlsport = '40500'  # можно посмотреть номер порта командой "cat /tmp/ndnproxymain.stat"
dnsoverhttpsport = '40508'  # можно посмотреть номер порта командой "cat /tmp/ndnproxymain.stat"

# ЕСЛИ ВЫ ХОТИТЕ ПОДДЕРЖАТЬ РАЗРАБОТЧИКОВ - МОЖЕТЕ ОТПРАВИТЬ ДОНАТ НА ЛЮБУЮ СУММУ
# ziwork aka NetworK - 4817 7603 0990 8527 (Сбербанк VISA)
# tas-unn aka Materland - 2204 1201 0098 8217 (КАРТА МИР)