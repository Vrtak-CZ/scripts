#!/bin/bash

##########
# Config #
##########
CONF_VHOSTS_DIR="/etc/nginx/vhosts"
CONF_VHOST_SKEL="/etc/nginx/vhost.skel"
CONF_HOSTS_FILE="/etc/hosts"
CONF_SERVER_DAEMON="nginx"
CONF_SERVER_RELOAD="reload"
CONF_IP="127.0.0.1"

#############
# Read args #
#############
VHOST_NAME=$1
VHOST_DOCROOT=$2
VHOST_DOMAINS=$3

############
# Var init #
############
FILE="$CONF_VHOSTS_DIR/$VHOST_NAME"

cat <<EOF
Vhost creator 0.1
=================
EOF

# Verifi args
if [ `whoami` != "root" ]
then
	echo "Please run as root" >&2
#elif [[ -n "$VHOST_NAME" && -n "$VHOST_DOCROOT" && -n "$VHOST_DOMAINS" ]]
elif [ $# == 3 ]
then
	if [ ! -d "$CONF_VHOSTS_DIR" ]
	then
		echo "Vhosts dir ${CONF_VHOSTS_DIR} does not exist" >&2
	elif [ ! -f "$CONF_VHOST_SKEL" ]
	then
		echo "Vhost skeleton file ${CONF_VHOST_SKEL} does not exist" >&2
	elif [ ! -d "$VHOST_DOCROOT" ]
	then
		echo "Vhost document root ${VHOST_DOCROOT} does not exist" >&2
	elif [ -f "$FILE" ]
	then
		echo "Vhost file ${FILE} allready exist" >&2
	else
		echo "Creating file"
		cp "${CONF_VHOST_SKEL}" "${FILE}"
		sed -i -e "s,{{DOMAINS}},${VHOST_DOMAINS},g" "${FILE}"
		sed -i -e "s,{{DOCROOT}},${VHOST_DOCROOT},g" "${FILE}"

		echo "Adding host to hosts"
		echo "${CONF_IP} ${VHOST_DOMAINS}" >> "${CONF_HOSTS_FILE}"

		echo "Reloading server"
		echo `systemctl $CONF_SERVER_RELOAD $CONF_SERVER_DAEMON`
	fi
else
	cat <<EOF
Params:
 - vhost name
 - document root
 - domains ("foo.local bar.local")

EOF
fi
