#!/bin/sh

# install_rivendell_devel.sh
#
# Install the Rivendell 4.x development tools on an Ubuntu 24.04 system
#
#    Copyright (C) 2021-2024 Fred Gleason <fredg@paravelsystems.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License as
#    published by the Free Software Foundation;
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, 
#    Boston, MA  02111-1307  USA
#

#
# Install Packages
#
apt install apache2 libexpat1-dev libexpat1 libid3-dev libcurl4-gnutls-dev libcoverart-dev libdiscid-dev libmusicbrainz5-dev libcdparanoia-dev libsndfile1-dev libpam0g-dev libvorbis-dev python3 python3-pycurl python3-pymysql python3-serial python3-requests libsamplerate0-dev qtbase5-dev libqt5sql5-mysql libsoundtouch-dev libsystemd-dev libjack-jackd2-dev libasound2-dev libflac-dev libflac++-dev libmp3lame-dev libmad0-dev libtwolame-dev docbook5-xml libxml2-utils docbook-xsl-ns xsltproc fop make g++ libltdl-dev autoconf automake libssl-dev libtag1-dev qttools5-dev-tools debhelper autoconf-archive gnupg pbuilder ubuntu-dev-tools apt-file hpklinux-dev

#
# Configure Environment
#
echo "export DOCBOOK_STYLESHEETS=/usr/share/xml/docbook/stylesheet/docbook-xsl-ns" > /etc/profile.d/docbook5.sh
