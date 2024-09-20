#!/bin/bash

# Variables
VER=1.5.5
PASSWD=somepasswordhere
ENC_PASSWORD=$(echo -n $PASSWD | openssl md5 | awk '{print $2}')

# Update and install dependencies
sudo sed -i '/cdrom/d' /etc/apt/sources.list
sudo apt update
sudo apt install -y build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin uuid-dev libossp-uuid-dev \
libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev \
libvncserver-dev libtelnet-dev libwebsockets-dev libssl-dev libvorbis-dev libwebp-dev libpulse-dev sudo vim \
postgresql postgresql-contrib

# Download and install Guacamole server
wget https://downloads.apache.org/guacamole/$VER/source/guacamole-server-$VER.tar.gz
tar xzf guacamole-server-$VER.tar.gz
cd guacamole-server-$VER
./configure --with-systemd-dir=/etc/systemd/system/
make
sudo make install
sudo ldconfig
sudo systemctl daemon-reload
sudo sed -i '/^::1/s/^/#/g' /etc/hosts
sudo systemctl enable --now guacd

# Install Tomcat
echo "deb http://deb.debian.org/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/bullseye.list
sudo apt update
sudo apt install -y tomcat9 tomcat9-admin tomcat9-common tomcat9-user
sudo sed -i 's/^/#/' /etc/apt/sources.list.d/bullseye.list
sudo systemctl status tomcat9.service

# Setup Guacamole
sudo mkdir /etc/guacamole
wget https://downloads.apache.org/guacamole/$VER/binary/guacamole-$VER.war -O /etc/guacamole/guacamole.war
sudo ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/
sudo systemctl restart tomcat9 guacd
sudo mkdir /etc/guacamole/{extensions,lib}
echo "GUACAMOLE_HOME=/etc/guacamole" | sudo tee -a /etc/default/tomcat9
echo "GUACAMOLE_HOME=/etc/guacamole" | sudo tee -a /etc/profile.d/tomcat9.sh

# Create guacamole.properties
sudo tee /etc/guacamole/guacamole.properties > /dev/null << EOL
guacd-hostname: 127.0.0.1
guacd-port: 4822
user-mapping: /etc/guacamole/user-mapping.xml
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
EOL

sudo ln -s /etc/guacamole /usr/share/tomcat9/.guacamole

# Create user-mapping.xml
sudo tee /etc/guacamole/user-mapping.xml > /dev/null << EOF
<user-mapping>
    <authorize username="guacadmin" password="5f4dcc3b5aa765d61d8327deb882cf99" encoding="md5">
        <connection name="Ubuntu 22">
            <protocol>ssh</protocol>
            <param name="hostname">192.168.58.37</param>
            <param name="port">22</param>
        </connection>
        <connection name="Windows 10">
            <protocol>rdp</protocol>
            <param name="hostname">192.168.56.121</param>
            <param name="port">3389</param>
            <param name="username">kifarunix</param>
            <param name="ignore-cert">true</param>
        </connection>
    </authorize>
</user-mapping>
EOF

sudo systemctl restart tomcat9 guacd

# Database setup
wget https://jdbc.postgresql.org/download/postgresql-42.7.3.jar
wget https://apache.org/dyn/closer.lua/guacamole/$VER/binary/guacamole-auth-jdbc-$VER.tar.gz?action=download
sudo mv postgresql-42.7.3.jar /etc/guacamole/lib/
mv guacamole-auth-jdbc-$VER.tar.gz\?action\=download guacamole-auth-jdbc-$VER.tar.gz
tar -xvzf guacamole-auth-jdbc-$VER.tar.gz
cd guacamole-auth-jdbc-$VER/postgresql
sudo mv guacamole-auth-jdbc-postgresql-$VER.jar /etc/guacamole/extensions/
sudo mkdir /tmp/schema
sudo mv schema/*.sql /tmp/schema
sudo chmod 0755 -R /tmp/schema

# PostgreSQL setup
sudo -i -u postgres << EOF
createdb guacamole_db
cd /tmp/schema
cat ./*.sql | psql -d guacamole_db -f -
psql -d guacamole_db << SQL
CREATE USER guacamole_user WITH PASSWORD 'some_password';
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO guacamole_user;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO guacamole_user;
SQL
EOF

# Restart services
sudo systemctl restart tomcat9 guacd