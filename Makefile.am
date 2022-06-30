## automake.am
##
## Top level automake.am for the ubuntu-rivendell-installer package.
##
##   (C) Copyright 2021 Fred Gleason <fredg@paravelsystems.com>
##
##   This program is free software; you can redistribute it and/or modify
##   it under the terms of the GNU General Public License version 2 as
##   published by the Free Software Foundation.
##
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.
##
##   You should have received a copy of the GNU General Public
##   License along with this program; if not, write to the Free Software
##   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
##
## Use automake to process this into a Makefile.in

if DOCBOOK_AM
  DOCBOOK_AM_OPT = docs
endif

SUBDIRS = assets\
          debian\
          scripts\
          $(DOCBOOK_AM_OPT)

ACLOCAL_AMFLAGS = -I m4

maintainer-clean-local:	
	rm -rf m4

howto:	all
	rsync -rptgoDv --delete docs/*.html docs/*.png software.paravelsystems.com::howtos/ubuntu/jammy/

deb:	dist
	./build_debs.sh

EXTRA_DIST = autogen.sh\
             build_debs.sh.in\
             get_distro.pl\
             get_target.sh\
             PACKAGE_VERSION

CLEANFILES = *~\
             *.buildinfo\
             *.changes\
             *.ddeb\
             *.deb\
             *.dsc\
             *.mo\
             *.rpm\
             *.tar.gz\
             *.tar.xz\
             *.tgz\
             *.zip\
             py-compile

DISTCLEANFILES = config.guess\
                 config.sub

MAINTAINERCLEANFILES = *~\
                       *.tar.gz\
                       aclocal.m4\
                       Makefile.in\
                       config.guess\
                       config.status\
                       config.sub\
                       configure\
                       depcomp\
                       install-sh\
                       libtool\
                       ltmain.sh\
                       missing\
                       mkinstalldirs
