#!/bin/sh

if [[ "$@" == "opennebula-hem start" ]]; then
	su oneadmin - -c "ruby /usr/lib/one/onehem/onehem-server.rb &"
elif [[ "$@" == "opennebula-hem stop" ]]; then
	pkill -u oneadmin -f onehem-server.rb
else
	exit 1
fi
