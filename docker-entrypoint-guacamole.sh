#!/bin/bash
set -e

echo "Executing $BASH_SOURCE"
if [ "$1" = "/usr/bin/supervisord" ]; then
	# use samble configuration with no auth if no configuration is supplied
	if [ -z "$(ls -A "/etc/guacamole")" ]; then
		echo "Copy default configuration"
		cp -R /usr/share/guacamole/examples/noauth/. /etc/guacamole
	fi
fi

