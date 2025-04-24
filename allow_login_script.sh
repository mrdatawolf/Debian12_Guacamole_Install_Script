#!/bin/bash


useradd -M -d /var/lib/guacd/ -r -s /sbin/nologin -c "Guacd User" guacd
mkdir /var/lib/guacd
chown -R guacd: /var/lib/guacd
sed -i 's/daemon/guacd/' /etc/systemd/system/guacd.service
systemctl daemon-reload
restart guacd