## Makefile.am
##
## docs/Makefile.am for ubuntu-rivendell-installer
##
## (C) Copyright 2021 Fred Gleason <fredg@paravelsystems.com>
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

##
## Build Dependencies
##
%.html:	%.xml
	xsltproc -o $@ $(DOCBOOK_STYLESHEETS)/xhtml/docbook.xsl $<
%.pdf:	%.xml
	xsltproc $(DOCBOOK_STYLESHEETS)/fo/docbook.xsl $< | fop - -pdf $@

all-local:	index.html

EXTRA_DIST = bootscreen.png\
             incomplete_language_support.png\
             installation_complete.png\
             installation_type.png\
             index.html\
             index.xml\
             installer_menu.png\
             keyboard_layout.png\
             opening_terminal.png\
             slideshow.png\
             software_on_this_computer_is_up_to_date.png\
             terminal_window.png\
             updated_software_has_been_issued.png\
             updates_and_other_software.png\
             user_rd_password_prompt.png\
             welcome.png\
             where_are_you.png\
             who_are_you.png


CLEANFILES = *~
MAINTAINERCLEANFILES = *~\
                       *.1\
                       *.8\
                       *.html\
                       *.pdf\
                       aclocal.m4\
                       configure\
                       Makefile.in
