#!/bin/bash
#SET THE VERSION TO THE ONE YOU WANT. 1.5.5 IS CURRENT AS OF JUN 2024
VER=1.5.5
#guacamole user password for DB
PASSWORD=Apassword5
sed -i '/^deb cdrom:/s/^/#/' /etc/apt/sources.list
apt-get update
apt-get install -y build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev	libtool-bin uuid-dev libossp-uuid-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev libwebsockets-dev libssl-dev libvorbis-dev libwebp-dev libpulse-dev sudo vim postgresql postgresql-contrib
wget https://downloads.apache.org/guacamole/$VER/source/guacamole-server-$VER.tar.gz
tar xzf guacamole-server-$VER.tar.gz
cd guacamole-server-$VER
./configure --with-systemd-dir=/etc/systemd/system/
make
make install
ldconfig
systemctl daemon-reload
sed -i '/^::1/s/^/#/g' /etc/hosts
systemctl restart guacd
echo "deb http://deb.debian.org/debian/ bullseye main" > /etc/apt/sources.list.d/bullseye.list
apt-get update
apt-get install tomcat9 tomcat9-admin tomcat9-common tomcat9-user -y
sed -i 's/^/#/' /etc/apt/sources.list.d/bullseye.list 
mkdir /etc/guacamole
wget https://downloads.apache.org/guacamole/$VER/binary/guacamole-$VER.war -O /etc/guacamole/guacamole.war
ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/
systemctl restart tomcat9 guacd
mkdir /etc/guacamole/{extensions,lib}
echo "GUACAMOLE_HOME=/etc/guacamole" >> /etc/default/tomcat9
echo "GUACAMOLE_HOME=/etc/guacamole" >> /etc/profile.d/tomcat9.sh
cat > /etc/guacamole/guacamole.properties << EOL
guacd-hostname: 127.0.0.1
guacd-port: 4822
user-mapping:   /etc/guacamole/user-mapping.xml
auth-provider:  net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
EOL
ln -s /etc/guacamole /usr/share/tomcat9/.guacamole
cat > /etc/guacamole/user-mapping.xml << EOL
<user-mapping>
    <!-- Per-user authentication and config information -->
    <!-- A user using md5 to hash the password guacadmin user and its md5 hashed password below is used to login to Guacamole Web UI-->
    <authorize username="guacadmin" password="5f4dcc3b5aa765d61d8327deb882cf99" encoding="md5">
       
    </authorize>
</user-mapping>
EOL
wget https://jdbc.postgresql.org/download/postgresql-42.7.3.jar -O /etc/guacamole/lib/postgresql-42.7.3.jar
wget https://dlcdn.apache.org/guacamole/$VER/binary/guacamole-auth-jdbc-$VER.tar.gz -O guacamole-auth-jdbc-$VER.tar.gz
tar -xvzf guacamole-auth-jdbc-$VER.tar.gz
cd ./guacamole-auth-jdbc-$VER/postgresql
mv guacamole-auth-jdbc-postgresql-$VER.jar /etc/guacamole/extensions/
mkdir /tmp/schema
mv ./guacamole-auth-jdbc-$VER/postgresql/schema/*.sql /tmp/schema
chmod 0777 -R /tmp/schema
cat >  /etc/guacamole/guacamole.properties << EOL
    postgresql-hostname: localhost
    postgresql-database: guacamole_db
    postgresql-username: guacamole_user
    postgresql-password: $PASSWORD
    auth-provider: org.apache.guacamole.auth.postgresql.PostgreSQLAuthenticationProvider
EOL
cd /tmp
sudo -u postgres createdb guacamole_db 
sudo -u postgres bash -c "cat schema/*.sql | psql -d guacamole_db -f -"
sudo -u postgres psql -d guacamole_db -c "CREATE USER guacamole_user WITH PASSWORD '$PASSWORD';"
sudo -u postgres psql -d guacamole_db -c "GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO guacamole_user;"
sudo -u postgres psql -d guacamole_db -c "GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO guacamole_user;"
rm -rf /var/lib/tomcat9/webapps/ROOT
mv /var/lib/tomcat9/webapps/guacamole /var/lib/tomcat9/webapps/ROOT
systemctl restart tomcat9 guacd
