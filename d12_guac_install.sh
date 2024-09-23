#!/bin/bash

set -e

# Variable setup
DEFAULT_VER=1.5.5
read -p "Enter the password for the PostgreSQL user: " PASSWD
read -p "Enter the Guacamole version (default is $DEFAULT_VER): " VER
VER=${VER:-$DEFAULT_VER}

# Functions
update_and_install_dependencies() {
    sudo sed -i '/cdrom/d' /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get install -y build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin uuid-dev libossp-uuid-dev \
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev \
    libvncserver-dev libtelnet-dev libwebsockets-dev libssl-dev libvorbis-dev libwebp-dev libpulse-dev sudo vim \
    postgresql postgresql-contrib
}

download_and_install_guacamole_server() {
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
}

install_tomcat() {
    echo "deb http://deb.debian.org/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/bullseye.list
    sudo apt-get update
    sudo apt-get install -y tomcat9 tomcat9-admin tomcat9-common tomcat9-user
    sudo sed -i 's/^/#/' /etc/apt/sources.list.d/bullseye.list
    sudo systemctl status tomcat9.service
}

setup_guacamole() {
    sudo mkdir /etc/guacamole
    wget https://downloads.apache.org/guacamole/$VER/binary/guacamole-$VER.war -O /etc/guacamole/guacamole.war
    sudo ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/
    sudo systemctl restart tomcat9 guacd
    sudo mkdir /etc/guacamole/{extensions,lib}
    echo "GUACAMOLE_HOME=/etc/guacamole" | sudo tee -a /etc/default/tomcat9
    echo "GUACAMOLE_HOME=/etc/guacamole" | sudo tee -a /etc/profile.d/tomcat9.sh
}

create_guacamole_properties() {
    sudo tee /etc/guacamole/guacamole.properties > /dev/null << EOL
guacd-hostname: 127.0.0.1
guacd-port: 4822
# Remove user-mapping line
# user-mapping: /etc/guacamole/user-mapping.xml
auth-provider: net.sourceforge.guacamole.net.auth.postgresql.PostgreSQLAuthenticationProvider
postgresql-hostname: localhost
postgresql-port: 5432
postgresql-database: guacamole_db
postgresql-username: guacamole_user
postgresql-password: $PASSWD
EOL

    sudo ln -s /etc/guacamole /usr/share/tomcat9/.guacamole
}

setup_database() {
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
}

setup_postgresql() {
    sudo -i -u postgres << EOF
createdb guacamole_db
cd /tmp/schema
cat ./*.sql | psql -d guacamole_db -f -
psql -d guacamole_db << SQL
CREATE USER guacamole_user WITH PASSWORD '$PASSWD';
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO guacamole_user;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO guacamole_user;
SQL
EOF
}

restart_services() {
    sudo systemctl restart tomcat9 guacd
}

# Main script
update_and_install_dependencies
download_and_install_guacamole_server
install_tomcat
setup_guacamole
create_guacamole_properties
setup_database
setup_postgresql
restart_services
