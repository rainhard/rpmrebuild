#!/usr/bin/env sh
###############################################################################
#   demofiles.sh
#      it's a part of the rpmrebuild project
#
#    Copyright (C) 2004 by Eric Gerbier
#    Bug reports to: eric.gerbier@tutanota.com
#      or          : valery_reznic@users.sourceforge.net
#    $Id$
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
###############################################################################
# code's file of changefile plugin for rpmrebuild

version=1.0
###############################################################################
function msg () {
	echo >&2 $*
}
###############################################################################
function syntaxe () {
	msg "this plugin allow change a file in a package"
	msg "it must be called with --change-files option"
	msg "-d|--dest : relative path in the rpm of the file to be changed"
	msg "-s|--src  : path of the file used to replace the rpm file"
	msg "-h|--help : this help"
	msg "-v|--version : print plugin version"
	exit 1

}
###############################################################################

# test for arguments
while [[ $1 ]]
do
	case $1 in
	-h | --help )
		syntaxe
	;;

        -v | --version )
                msg "$0 version $version";
                exit 1;
        ;;

	-d | --dest )
		DEST=$2
		shift 2
	;;

	-s | --src )
		SRC=$2
		shift 2
	;;

	*)
		msg "bad option : $1";
		syntaxe
	;;
	esac
done

# check if we have src and dest
echo "src=$SRC dest=$DEST"

# test the way to be called
case $LONG_OPTION in
	change-files)
		;;
		*)	msg "bad option : $LONG_OPTION (should be called from change-files)";
		syntaxe
	;;
esac

# go to the directory which contains all package's files
# in the same tree as the installed files :
# if the package contains /etc/cron.daily files, you will find etc/cron.daily directory here
cd $RPM_BUILD_ROOT

# you can now do what you want on the files : 
# add, remove, move, rename files (be carefull, you have to change the %files section too)
# modify files, change perms ...
if [ -f $DEST ]
then
	ls -l $DEST $SRC 
	diff $DEST $SRC 
	cp $SRC $DEST
else
	msg "can not find $DEST file"
fi
