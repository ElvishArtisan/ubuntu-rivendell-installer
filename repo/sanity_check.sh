#!/bin/bash

. /etc/os-release

if test "$ID" != "ubuntu" ; then
   echo "unexpected distro ID"
   exit 1
fi

if test "$VERSION_ID" != "24.04" ; then
   echo "unexpected distro VERSION_ID"
   exit 1
fi

exit 0
