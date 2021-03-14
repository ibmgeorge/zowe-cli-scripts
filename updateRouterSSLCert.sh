#!/bin/bash
echo "Auto upload let's encrypt certificate to Asus Router (asuswrt-merlin firmware)"
echo "Make sure 1. ssh enabled on router 192.168.1.1"
echo "Either run sudo ssh-keygen && sudo ssh-copy-id admin@192.168.1.1 once for good."
echo "Or manually type in admin password a few times."
certbot-auto renew
#sudo mkdir /tmp/.asuswrt-cert
#sudo cp /etc/letsencrypt/live/zos.duckdns.org/fullchain.pem /tmp/.asuswrt-cert/cert.pem
#sudo cp /etc/letsencrypt/live/zos.duckdns.org/privkey.pem /tmp/.asuswrt-cert/key.pem
#sudo tar -C / -czf /tmp/.asuswrt-cert/cert.tgz /tmp/.asuswrt-cert/cert.pem /tmp/.asuswrt-cert/key.pem
sudo scp /etc/letsencrypt/live/zos.duckdns.org/fullchain.pem admin@192.168.1.1:/jffs/.cert/cert.pem
sudo scp /etc/letsencrypt/live/zos.duckdns.org/privkey.pem admin@192.168.1.1:/jffs/.cert/key.pem
sudo ssh admin@192.168.1.1 'rm /etc/cert.pem /etc/key.pem /etc/server.pem'
sudo ssh admin@192.168.1.1 'nvram set https_crt_save=1'
sudo ssh admin@192.168.1.1 'service restart_httpd'
# sudo rm -rf /tmp/.asuswrt-cert/
