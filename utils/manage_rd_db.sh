#!/bin/bash

# manage_rd_db.sh
#
# Create and remove Rivendell database containers/configuration.
#
#   (C) Copyright 2025 Fred Gleason <fredg@paravelsystems.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License version 2 as
#   published by the Free Software Foundation.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

USAGE="manage_rd_db.sh add|drop <base-name>"

if test $UID != "0" ; then
    echo "this utility requires root permissions"
    exit 1
fi

if test $# != "2" ; then
    echo $USAGE
    exit 1
fi

VERB=$1
BASE_NAME=$2
CONFIG_NAME="/etc/rivendell.d/rd-"$BASE_NAME".conf"

#
# Sanity Check Section
#
if test ! -f /etc/rivendell.d/template.conf ; then
    echo "No configuration template file found at \"/etc/rivendell.d/template.conf"
    exit 1
fi

case "$VERB" in
    add)
	# Prompt for confirmation
	echo "This will add a \""$BASE_NAME"\" database, along with its associated"
	echo -n "configuration. Proceed (y/N)? "
	read RESP
	if test $RESP != "y" -a $RESP != "Y" ; then
	    exit 1
	fi
	;;

    drop)
	echo "This will completely delete the \""$BASE_NAME"\" database, along with its associated"
	echo -n "configuration. This operation cannot be undone! Proceed (y/N)? "
	read RESP
	if test -z $RESP ; then
	    exit 1
	fi
	if test $RESP != "y" -a $RESP != "Y" ; then
	    exit 1
	fi
	;;

    *)
	echo $USAGE
	exit 1
	;;
esac

#
# Database Section
#
case "$VERB" in
    add)
	# Create database
	echo "create database "$BASE_NAME\; | mysql -u root

	# Create user
	echo "CREATE USER '$BASE_NAME'@'localhost' IDENTIFIED BY '$BASE_NAME';" | mysql -u root

	# Provision database access for user
	echo "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER,CREATE TEMPORARY TABLES,LOCK TABLES ON $BASE_NAME.* TO '$BASE_NAME'@'localhost';" | mysql -u root
	;;
    drop)	
	# Drop user
	echo "drop user "$BASE_NAME@localhost\; | mysql -u root

	# Drop database 
	echo "drop database "$BASE_NAME\; | mysql -u root
	;;
esac

#
# Configuration Section
#
case "$VERB" in
    add)
	cat /etc/rivendell.d/template.conf | sed s/%MYSQL_LOGINNAME%/$BASE_NAME/ |sed s/%MYSQL_PASSWORD%/$BASE_NAME/ |sed s/%MYSQL_DBNAME%/$BASE_NAME/ > $CONFIG_NAME
	;;

    drop)
	rm -f $CONFIG_NAME
	;;
esac
