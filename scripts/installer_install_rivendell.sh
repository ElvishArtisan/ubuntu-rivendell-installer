#!/bin/bash

# install_rivendell.sh
#
# Install Rivendell 4.x on an Ubuntu 22.04 system
#

# USAGE: AddDbUser <dbname> <hostname> <username> <password>
function AddDbUser {
    echo "CREATE USER '${3}'@'${2}' IDENTIFIED BY '${4}';" | mysql -u root
    echo "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER,CREATE TEMPORARY TABLES,LOCK TABLES ON ${1}.* TO '${3}'@'${2}';" | mysql -u root
}

function GenerateDefaultRivendellConfiguration {
    mkdir -p /etc/rivendell.d
    cat /usr/share/ubuntu-rivendell-installer/rd.conf-sample | sed s/%MYSQL_HOSTNAME%/$MYSQL_HOSTNAME/g | sed s/%MYSQL_LOGINNAME%/$MYSQL_LOGINNAME/g | sed s/%MYSQL_PASSWORD%/$MYSQL_PASSWORD/g | sed s^%NFS_MOUNT_SOURCE%^$NFS_MOUNT_SOURCE^g | sed s/%NFS_MOUNT_TYPE%/$NFS_MOUNT_TYPE/g > /etc/rivendell.d/rd-default.conf
    ln -s -f /etc/rivendell.d/rd-default.conf /etc/rd.conf
}

#
# Get Target Mode
#
if test $1 ; then
    case "$1" in
	--client)
	    MODE="client"
            MYSQL_HOSTNAME=$2
            MYSQL_LOGINNAME=$3
            MYSQL_PASSWORD=$4
            MYSQL_DATABASE=$5
            NFS_HOSTNAME=$6
            NFS_MOUNT_SOURCE=$NFS_HOSTNAME:/var/snd
            NFS_MOUNT_TYPE="nfs"
	    ;;

	--server)
	    MODE="server"
            MYSQL_HOSTNAME="localhost"
            MYSQL_LOGINNAME="rduser"
            MYSQL_PASSWORD=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`
            MYSQL_DATABASE="Rivendell"
            NFS_HOSTNAME=""
            NFS_MOUNT_SOURCE=""
            NFS_MOUNT_TYPE=""
	    ;;

	--standalone)
	    MODE="standalone"
            MYSQL_HOSTNAME="localhost"
            MYSQL_LOGINNAME="rduser"
            MYSQL_PASSWORD=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`
            MYSQL_DATABASE="Rivendell"
            NFS_HOSTNAME=""
            NFS_MOUNT_SOURCE=""
            NFS_MOUNT_TYPE=""
	    ;;

	*)
            echo "invalid invocation!"
	    exit 256
            ;;
    esac
else
    echo "no mode specified!"
    exit 256
fi

#
# Dump Input Values
#
echo -n "MODE: " >> /root/rivendell_install_log.txt
echo $MODE >> /root/rivendell_install_log.txt

echo -n "MYSQL_HOSTNAME: " >> /root/rivendell_install_log.txt
echo $MYSQL_HOSTNAME >> /root/rivendell_install_log.txt

echo -n "MYSQL_LOGINNAME: " >> /root/rivendell_install_log.txt
echo $MYSQL_LOGINNAME >> /root/rivendell_install_log.txt

echo -n "MYSQL_PASSWORD: " >> /root/rivendell_install_log.txt
echo $MYSQL_PASSWORD >> /root/rivendell_install_log.txt

echo -n "MYSQL_DATABASE: " >> /root/rivendell_install_log.txt
echo $MYSQL_DATABASE >> /root/rivendell_install_log.txt

echo -n "NFS_HOSTNAME: " >> /root/rivendell_install_log.txt
echo $NFS_HOSTNAME >> /root/rivendell_install_log.txt

echo -n "NFS_MOUNT_SOURCE: " >> /root/rivendell_install_log.txt
echo $NFS_MOUNT_SOURCE >> /root/rivendell_install_log.txt

echo -n "NFS_MOUNT_TYPE: " >> /root/rivendell_install_log.txt
echo $NFS_MOUNT_TYPE >> /root/rivendell_install_log.txt

#
# Install Dependencies
#
apt -y install openssh-server patch evince telnet samba chrony emacs nfs-common smbclient net-tools traceroute gedit ntfs-3g autofs

if test $MODE = "server" ; then
    #
    # Install MariaDB
    #
    apt -y install mariadb-server
    cp -f /usr/share/ubuntu-rivendell-installer/90-rivendell.cnf /etc/mysql/mysql.conf.d/

    #
    # Create Empty Database
    #
    echo "CREATE DATABASE $MYSQL_DATABASE;" | mysql -u root
    AddDbUser $MYSQL_DATABASE "localhost" $MYSQL_LOGINNAME $MYSQL_PASSWORD
    AddDbUser $MYSQL_DATABASE "%" $MYSQL_LOGINNAME $MYSQL_PASSWORD

    #
    # Enable NFS Access for all remote hosts
    #
    mkdir -p /home/rd/rd_xfer
    chown rd:rd /home/rd/rd_xfer

    mkdir -p /home/rd/music_export
    chown rd:rd /home/rd/music_export

    mkdir -p /home/rd/music_import
    chown rd:rd /home/rd/music_import

    mkdir -p /home/rd/traffic_export
    chown rd:rd /home/rd/traffic_export

    mkdir -p /home/rd/traffic_import
    chown rd:rd /home/rd/traffic_import

    apt -y install nfs-kernel-server
    mkdir -p /srv/nfs4/var/snd
    mkdir -p /srv/nfs4/home/rd/music_export
    mkdir -p /srv/nfs4/home/rd/music_import
    mkdir -p /srv/nfs4/home/rd/traffic_export
    mkdir -p /srv/nfs4/home/rd/traffic_import
    mkdir -p /srv/nfs4/home/rd/rd_xport

    echo "/var/snd /srv/nfs4/var/snd none bind 0 0" >> /etc/fstab
    echo "/home/rd/music_export /srv/nfs4/home/rd/music_export none bind 0 0" >> /etc/fstab
    echo "/home/rd/music_import /srv/nfs4/home/rd/music_import none bind 0 0" >> /etc/fstab
    echo "/home/rd/traffic_export /srv/nfs4/home/rd/traffic_export none bind 0 0" >> /etc/fstab
    echo "/home/rd/traffic_import /srv/nfs4/home/rd/traffic_import none bind 0 0" >> /etc/fstab
    echo "/home/rd/rd_xfer /srv/nfs4/home/rd/rd_xfer none bind 0 0" >> /etc/fstab
    echo "/var/snd *(rw,no_root_squash)" >> /etc/exports
    echo "/home/rd/rd_xfer *(rw,no_root_squash)" >> /etc/exports
    echo "/home/rd/music_export *(rw,no_root_squash)" >> /etc/exports
    echo "/home/rd/music_import *(rw,no_root_squash)" >> /etc/exports
    echo "/home/rd/traffic_export *(rw,no_root_squash)" >> /etc/exports
    echo "/home/rd/traffic_import *(rw,no_root_squash)" >> /etc/exports

    #
    # Enable CIFS File Sharing
    #
    cp /etc/samba/smb.conf /etc/samba/smb-original.conf
    cat /usr/share/ubuntu-rivendell-installer/samba_shares.conf >> /etc/samba/smb.conf
fi

if test $MODE = "standalone" ; then
    #
    # Install MySQL
    #
    apt -y install mariadb-server

    #
    # Create Empty Database
    #
    echo "CREATE DATABASE Rivendell;" | mysql -u root
    AddDbUser $MYSQL_DATABASE "localhost" $MYSQL_LOGINNAME $MYSQL_PASSWORD

    #
    # Enable CIFS File Sharing
    #
    cp /etc/samba/smb.conf /etc/samba/smb-original.conf
    cat /usr/share/ubuntu-rivendell-installer/samba_shares.conf >> /etc/samba/smb.conf
    systemctl enable smbd
    systemctl enable nmbd
fi

#
# Install Rivendell
#
patch -p0 /etc/rsyslog.d/50-default.conf /usr/share/ubuntu-rivendell-installer/50-default.conf.patch
rm -f /etc/asound.conf
cp /usr/share/ubuntu-rivendell-installer/asound.conf /etc/
mkdir -p /usr/share/pixmaps/rivendell
cp /usr/share/ubuntu-rivendell-installer/rdairplay_skin.png /usr/share/pixmaps/rivendell/
cp /usr/share/ubuntu-rivendell-installer/rdpanel_skin.png /usr/share/pixmaps/rivendell/
cp /usr/share/ubuntu-rivendell-installer/paravel_support.pdf /home/rd/Desktop/First\ Steps.pdf
chown rd:rd /home/rd/Desktop/First\ Steps.pdf
ln -s /usr/share/rivendell/opsguide.pdf /home/rd/Desktop/Operations\ Guide.pdf
apt -y install lame rivendell rivendell-opsguide
cat /etc/rd.conf | sed s/SyslogFacility=1/SyslogFacility=23/g > /etc/rd-temp.conf
mv -f /etc/rd-temp.conf /etc/rd.conf
usermod -a --groups audio rd

GenerateDefaultRivendellConfiguration

if test $MODE = "server" ; then
    #
    # Initialize Automounter
    #
    cp -f /usr/share/ubuntu-rivendell-installer/auto.misc.template /etc/auto.misc
    systemctl enable autofs

    #
    # Create Rivendell Database
    #
    rddbmgr --create --generate-audio
    echo update\ \`STATIONS\`\ set\ \`REPORT_EDITOR_PATH\`=\'/usr/bin/gedit\' | mysql -u root Rivendell
fi

if test $MODE = "standalone" ; then
    #
    # Initialize Automounter
    #
    cp -f /usr/share/ubuntu-rivendell-installer/auto.misc.template /etc/auto.misc
    systemctl enable autofs

    #
    # Create Rivendell Database
    #
    rddbmgr --create --generate-audio
    echo update\ \`STATIONS\`\ set\ \`REPORT_EDITOR_PATH\`=\'/usr/bin/gedit\' | mysql -u root Rivendell

    #
    # Create common directories
    #
    mkdir -p /home/rd/rd_xfer
    chown rd:rd /home/rd/rd_xfer

    mkdir -p /home/rd/music_export
    chown rd:rd /home/rd/music_export

    mkdir -p /home/rd/music_import
    chown rd:rd /home/rd/music_import

    mkdir -p /home/rd/traffic_export
    chown rd:rd /home/rd/traffic_export

    mkdir -p /home/rd/traffic_import
    chown rd:rd /home/rd/traffic_import
fi

if test $MODE = "client" ; then
    #
    # Initialize Automounter
    #
    rm -f /etc/auto.rd.audiostore
    cat /usr/share/ubuntu-rivendell-installer/auto.rd.audiostore.template | sed s/@IP_ADDRESS@/$NFS_HOSTNAME/g > /etc/auto.rd.audiostore
    mkdir -p /misc/rd_xfer
    rm -f /home/rd/rd_xfer
    ln -s /misc/rd_xfer /home/rd/rd_xfer

    mkdir -p /misc/music_export
    rm -f /home/rd/music_export
    ln -s /misc/music_export /home/rd/music_export

    mkdir -p /misc/music_import
    rm -f /home/rd/music_import
    ln -s /misc/music_import /home/rd/music_import

    mkdir -p /misc/traffic_export
    rm -f /home/rd/traffic_export
    ln -s /misc/traffic_export /home/rd/traffic_export

    mkdir -p /misc/traffic_import
    rm -f /home/rd/traffic_import
    ln -s /misc/traffic_import /home/rd/traffic_import

    rm -f /etc/auto.misc
    cat /usr/share/ubuntu-rivendell-installer/auto.misc.client_template | sed s/@IP_ADDRESS@/$NFS_HOSTNAME/g > /etc/auto.misc
    systemctl enable autofs
fi

#
# Finish Up
#
echo
echo "Installation of Rivendell is complete.  Reboot now."
echo
