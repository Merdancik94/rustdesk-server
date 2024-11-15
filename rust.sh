#!/bin/bash

# Исправление символов переноса строк, если файл запущен с Windows-стилем (CRLF)
if file --mime-encoding "$0" | grep -q "with CRLF"; then
    sed -i 's/\r$//' "$0"
    echo "Исправлен стиль переноса строк в $0. Повторите запуск скрипта."
    exit 0
fi

# Определение текущего имени хоста
HOSTNAME=$(hostname)
HOST_ENTRY="127.0.0.1 $HOSTNAME"

# Проверка и обновление /etc/hosts
if ! grep -q "$HOST_ENTRY" /etc/hosts; then
    echo "$HOST_ENTRY" | sudo tee -a /etc/hosts
    echo "Имя хоста $HOSTNAME добавлено в /etc/hosts."
else
    echo "Имя хоста $HOSTNAME уже существует в /etc/hosts."
fi

# Обновление системы и установка зависимостей
echo "Обновление системы и установка зависимостей..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl unzip gnupg apt-transport-https

# Удаление ненужных пакетов
sudo apt autoremove -y

# Удаление дублирующихся записей в /etc/apt/sources.list
echo "Удаление дублирующихся записей в /etc/apt/sources.list..."
sudo awk '!x[$0]++' /etc/apt/sources.list > /tmp/sources.list && sudo mv /tmp/sources.list /etc/apt/sources.list

# Установка Node.js и PM2
echo "Установка Node.js и PM2..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2

# Проверка состояния UFW и его отключение, если он включён
if sudo ufw status | grep -q "Status: active"; then
    echo "UFW включён. Отключаем его..."
    sudo ufw disable
else
    echo "UFW уже отключён."
fi

# Создание необходимых директорий для сервера RustDesk
echo "Создание директорий для сервера RustDesk..."
mkdir -p /root/rustdesk-server/amd64

# Загрузка и распаковка RustDesk сервера
echo "Загрузка и распаковка RustDesk сервера..."
curl -LO https://github.com/rustdesk/rustdesk-server/releases/download/1.1.9/rustdesk-server-linux-amd64.zip
unzip -o rustdesk-server-linux-amd64.zip -d /root/rustdesk-server/amd64
mv /root/rustdesk-server/amd64/amd64/* /root/rustdesk-server/amd64/

# Запуск процессов hbbs и hbbr с помощью PM2
echo "Запуск процессов hbbs и hbbr с помощью PM2..."
pm2 start /root/rustdesk-server/amd64/hbbs --name hbbs
pm2 start /root/rustdesk-server/amd64/hbbr --name hbbr

# Настройка автозапуска PM2 при старте системы
pm2 save
pm2 startup systemd -u $(whoami) --hp $(eval echo ~$USER)

echo "Установка и запуск сервера RustDesk завершены!"
pm2 list
