#!/bin/bash

echo "Остановка процессов hbbs и hbbr, запущенных через PM2..."
pm2 stop hbbs
pm2 stop hbbr

echo "Удаление процессов hbbs и hbbr из PM2..."
pm2 delete hbbs
pm2 delete hbbr

echo "Удаление конфигурации PM2..."
pm2 unstartup systemd
pm2 save

echo "Удаление PM2 и Node.js..."
sudo npm uninstall -g pm2
sudo apt remove --purge -y nodejs npm

echo "Удаление директорий и файлов RustDesk сервера..."
sudo rm -rf /root/rustdesk-server
sudo rm -f rustdesk-server-linux-amd64.zip

echo "Очистка ненужных пакетов и зависимостей..."
sudo apt autoremove -y
sudo apt autoclean

echo "Удаление завершено."
