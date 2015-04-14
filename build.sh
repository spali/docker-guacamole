#!/bin/bash
set -e
#######################################################################################
# prepare apt
export DEBIAN_FRONTEND=noninteractive
#######################################################################################

echo "---------------------------------------------------------------------------------------"
echo " install required dependencies to build guacamole"
echo "---------------------------------------------------------------------------------------"
apt-get update
apt-get install -y --no-install-recommends git-core wget \
	default-jdk maven2 \
	libtool autoconf automake make \
	libcairo2-dev libpng12-dev libossp-uuid-dev \
	libfreerdp-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev libvorbis-dev \


echo "---------------------------------------------------------------------------------------"
echo " install and build guacamole server"
echo "---------------------------------------------------------------------------------------"
(
	git clone https://github.com/glyptodon/guacamole-server.git -b $GUAC_VER --single-branch /tmp/guacamole-server
	cd /tmp/guacamole-server
	autoreconf -fi
	./configure --with-init-dir=/etc/init.d
	make
	make install
	update-rc.d guacd defaults
	ldconfig
	ln -s /etc/guacamole /usr/share/tomcat7/.guacamole
)


echo "---------------------------------------------------------------------------------------"
echo " build and install guacamole client"
echo "---------------------------------------------------------------------------------------"
(
	git clone https://github.com/glyptodon/guacamole-client -b $GUAC_VER --single-branch /tmp/guacamole-client
	cd /tmp/guacamole-client
	mvn package
	rm -Rf /var/lib/tomcat7/webapps/*
	cp ./guacamole/target/guacamole-$GUAC_VER.war /var/lib/tomcat7/webapps/
	ln -s /var/lib/tomcat7/webapps/guacamole-$GUAC_VER.war /var/lib/tomcat7/webapps/ROOT.war
	ln -s /var/lib/tomcat7/webapps/guacamole-$GUAC_VER.war /var/lib/tomcat7/webapps/guacamole.war
	# install extensions
	mkdir -p /etc/guacamole /var/lib/guacamole/classpath /tmp/guacamole-modules
	cp ./extensions/guacamole-auth-ldap/target/guacamole-auth-ldap-$GUAC_VER.jar /var/lib/guacamole/classpath/
	cp ./extensions/guacamole-auth-noauth/target/guacamole-auth-noauth-$GUAC_VER.jar /var/lib/guacamole/classpath/
	cp ./extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-base/target/guacamole-auth-jdbc-base-$GUAC_VER.jar /var/lib/guacamole/classpath/
	cp ./extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-mysql/target/extension/guacamole-auth-jdbc-mysql-$GUAC_VER.jar /var/lib/guacamole/classpath/
	cp ./extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-postgresql/target/extension/guacamole-auth-jdbc-postgresql-$GUAC_VER.jar /var/lib/guacamole/classpath/
	# Download dependancies for postgresql authentication module
	wget -q --span-hosts -O /var/lib/guacamole/classpath/postgresql-${PCJ_VER}.jdbc41.jar https://jdbc.postgresql.org/download/postgresql-${PCJ_VER}.jdbc41.jar
	# Download dependancies for mysql authentication module
	wget -q --span-hosts -O /tmp/guacamole-modules/mysql-connector-java-${MCJ_VER}.tar.gz http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MCJ_VER}.tar.gz
	tar -zxf /tmp/guacamole-modules/mysql-connector-java-${MCJ_VER}.tar.gz -C /tmp/guacamole-modules/
	cp /tmp/guacamole-modules/mysql-connector-java-${MCJ_VER}/mysql-connector-java-${MCJ_VER}-bin.jar /var/lib/guacamole/classpath/
	# Copy sql shema files
	mkdir -p /root/mysql
	find ./extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-mysql -name '*.sql' -exec cp {} /root/mysql/ \;
	mkdir -p /root/postgresql
	find ./extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-postgresql -name '*.sql' -exec cp {} /root/postgresql/ \;
)

echo "---------------------------------------------------------------------------------------"
echo " install guacamole modules"
echo "---------------------------------------------------------------------------------------"
# Build and install HMAC Authentication module
(
	git clone https://github.com/grncdr/guacamole-auth-hmac.git /tmp/guacamole-modules/guacamole-auth-hmac
	cd /tmp/guacamole-modules/guacamole-auth-hmac
	mvn package
	cp ./target/guacamole-auth-hmac-*-SNAPSHOT.jar /var/lib/guacamole/classpath/
)


echo "---------------------------------------------------------------------------------------"
echo " Cleanup sources"
echo "---------------------------------------------------------------------------------------"
rm -Rf /tmp/guacamole-client
rm -Rf /tmp/guacamole-server
rm -Rf /tmp/guacamole-modules

echo "---------------------------------------------------------------------------------------"
echo " cleanup build dependencies (not required anymore)"
echo "---------------------------------------------------------------------------------------"
apt-get purge -y git-core wget \
	default-jdk maven2 \
	libtool autoconf automake make 
apt-get autoremove -y
apt-get clean
find /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	/usr/share/man /usr/share/groff /usr/share/info \
	/usr/share/lintian /usr/share/linda /var/cache/man -type f -exec rm -f {} \; || true
find /usr/share/doc -depth -type f ! -name copyright -exec rm -f {} \; || true

#######################################################################################

