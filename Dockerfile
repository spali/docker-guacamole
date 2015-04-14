FROM debian:wheezy

#######################################################################################

# Version of guacamole to be installed
ENV GUAC_VER 0.9.6
# Version of mysql-connector-java to install
ENV MCJ_VER 5.1.32
# Version of postgresql-connector-java to install
ENV PCJ_VER 9.4-1201

# Don't let apt install docs or man pages
ADD excludes /etc/dpkg/dpkg.cfg.d/excludes
# install required apackages
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends supervisor tomcat7 && \
	apt-get clean && \
	find /var/lib/apt/lists/* /tmp/* /var/tmp/* \
		/usr/share/man /usr/share/groff /usr/share/info \
		/usr/share/lintian /usr/share/linda /var/cache/man -type f -exec rm -f {} \; || true && \
	find /usr/share/doc -depth -type f ! -name copyright -exec rm -f {} \; 

# build and install guacamole and related components (wrapped script to minimize image commits and keep images small)
COPY build.sh /
RUN /bin/bash /build.sh
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

