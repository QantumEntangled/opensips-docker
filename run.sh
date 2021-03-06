#!/bin/bash

HOST_IP=$(ip route get 8.8.8.8 | head -n +1 | tr -s " " | cut -d " " -f 7)

#sed -i "s/listen=.*/listen=udp:${HOST_IP}:5060/g" /usr/local/etc/opensips/opensips.cfg

service rsyslog start
service apache2 start
service mysql start

iptables -t nat -A OUTPUT -o lo -p tcp --dport 8080 -j REDIRECT --to-port 3306

/usr/sbin/opensipsctl start

tail -f /var/log/opensips.log
