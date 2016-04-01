FROM alpine:3.3

#######################################################################################

# Version of maven to be installed
ENV MAVEN_VERSION 3.2.5
# Version of tomcat to be installed
ENV TOMCAT_VERSION 7.0.68
# Version of guacamole to be installed
ENV GUAC_VER 0.9.9
# Version of mysql-connector-java to install
ENV MCJ_VER 5.1.32
# Version of postgresql-connector-java to install
ENV PCJ_VER 9.4-1201

# prepare apt and system (first clean is required to prevent gpg keys errors)
RUN apk --update add curl

## install required apackages
RUN curl "https://archive.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" | tar -xzC /tmp
RUN mv /tmp/apache-tomcat* /usr/tomcat
RUN apk --update add supervisor openjdk7-jre

# build and install guacamole and related components (wrapped script to minimize image commits and keep images small)
COPY build.sh /
RUN /bin/sh /build.sh
RUN rm /build.sh

# add sample configuration for no auth
COPY examples /usr/share/guacamole/examples

#######################################################################################
COPY guacamole.conf /etc/supervisor/conf.d/
COPY docker-entrypoint.sh docker-entrypoint-guacamole.sh /
RUN chmod +x /docker-entrypoint.sh /docker-entrypoint-guacamole.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord -n"]
#######################################################################################
# expose volumnes
VOLUME [ "/etc/guacamole" ]
# expose ports
EXPOSE 8080
#######################################################################################

