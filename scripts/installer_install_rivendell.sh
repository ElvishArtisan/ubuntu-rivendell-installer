#!/bin/sh

# install_rivendell.sh
#
# Install Rivendell 4.x on an Ubuntu 20.04 system
#

#
# Site Defines
#
REPO_HOSTNAME="download.paravelsystems.com"

#
# Get Target Mode
#
if test $1 ; then
    case "$1" in
	--client)
	    MODE="client"
	    IP_ADDR=$2
	    ;;

	--server)
	    MODE="server"
	    ;;

	--standalone)
	    MODE="standalone"
	    ;;

	*)
	    echo "USAGE: ./install_rivendell.sh --client|--server|--standalone"
	    exit 256
            ;;
    esac
else
    MODE="standalone"
fi

#
# Install Dependencies
#
apt -y install openssh-server patch evince telnet samba ntp emacs nfs-common smbclient xfce4-screenshooter net-tools traceroute gedit ntfs-3g autofs

if test $MODE = "server" ; then
    #
    # Install MySQL
    #
    apt -y install mysql-server
    patch -p0 /etc/mysql/mysql.conf.d/mysqld.cnf /usr/share/ubuntu-rivendell-installer/mysqld.cnf-patch

    #
    # Enable DB Access for localhost
    #
    echo "CREATE DATABASE Rivendell;" | mysql -u root
    echo "CREATE USER 'rduser'@'localhost' IDENTIFIED BY 'letmein';" | mysql -u root
    echo "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER,CREATE TEMPORARY TABLES,LOCK TABLES ON Rivendell.* TO 'rduser'@'localhost';" | mysql -u root

    #
    # Enable DB Access for all remote hosts
    #
    echo "CREATE USER 'rduser'@'%' IDENTIFIED BY 'letmein';" | mysql -u root
    echo "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER,CREATE TEMPORARY TABLES,LOCK TABLES ON Rivendell.* TO 'rduser'@'%';" | mysql -u root

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
    apt -y install mysql-server

    #
    # Enable DB Access for localhost
    #
    echo "CREATE DATABASE Rivendell;" | mysql -u root
    echo "CREATE USER 'rduser'@'localhost' IDENTIFIED BY 'letmein';" | mysql -u root
    echo "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER,CREATE TEMPORARY TABLES,LOCK TABLES ON Rivendell.* TO 'rduser'@'localhost';" | mysql -u root

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
#cp /usr/share/ubuntu-rivendell-installer/*.repo /etc/yum.repos.d/
#cp /usr/share/ubuntu-rivendell-installer/RPM-GPG-KEY* /etc/pki/rpm-gpg/
mkdir -p /usr/share/pixmaps/rivendell
cp /usr/share/ubuntu-rivendell-installer/rdairplay_skin.png /usr/share/pixmaps/rivendell/
cp /usr/share/ubuntu-rivendell-installer/rdpanel_skin.png /usr/share/pixmaps/rivendell/
cp /usr/share/ubuntu-rivendell-installer/paravel_support.pdf /home/rd/Desktop/First\ Steps.pdf
chown rd:rd /home/rd/Desktop/First\ Steps.pdf
ln -s /usr/share/rivendell/opsguide.pdf /home/rd/Desktop/Operations\ Guide.pdf
apt -y install lame rivendell rivendell-opsguide

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
    echo "update `STATIONS` set `REPORT_EDITOR_PATH`='/usr/bin/gedit'" | mysql -u root Rivendell
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
    echo "update STATIONS set REPORT_EDITOR_PATH='/usr/bin/gedit'" | mysql -u root Rivendell

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
    cat /usr/share/ubuntu-rivendell-installer/auto.rd.audiostore.template | sed s/@IP_ADDRESS@/$IP_ADDR/g > /etc/auto.rd.audiostore
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
    cat /usr/share/ubuntu-rivendell-installer/auto.misc.client_template | sed s/@IP_ADDRESS@/$IP_ADDR/g > /etc/auto.misc
    systemctl enable autofs

    #
    # Configure Rivendell
    #
    cat /etc/rd.conf | sed s/localhost/$IP_ADDR/g > /etc/rd-temp.conf
    rm -f /etc/rd.conf
    mv /etc/rd-temp.conf /etc/rd.conf
fi

#
# Finish Up
#
echo
echo "Installation of Rivendell is complete.  Reboot now."
echo
echo "IMPORTANT: Be sure to see the FINAL DETAILS section in the instructions"
echo "           to ensure that your new Rivendell system is properly secured."
echo
