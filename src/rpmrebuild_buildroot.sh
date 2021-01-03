#!/usr/bin/env bash
###############################################################################
#   rpmrebuild_files.sh 
#      it's a part of the rpmrebuild project
#
#    Copyright (C) 2002, 2003, 2013 by Valery Reznic
#    Bug reports to: valery_reznic@users.sourceforge.net
#      or          : gerbier@users.sourceforge.net
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

################################################################
# This script get from stanard input data in the following format:
# <file_type>   - type of the file (as first field from 'ls -l' output)
# <file_flags>  - rpm file's flag (as %{FILEFLAGS:fflag}) - may be empty string
# <file_perm>   - file's permission (as %{FILEMODES:octal})
# <file_user>   - file's user id
# <file_group>  - file's group id
# <file_verify> - file's verify flags (as %{FILEVERIFYFLAGS:octal})
# <file_lang>   - file's language     (as %{FILELANGS})
# <file_caps>   - file's capablities  (as %{FILECAPS})
# <file>        - file name
#
# this format is used in the 3 scripts : 
# rpmrebuild_files.sh rpmrebuild_ghost.sh rpmrebuild_buildroot.sh
################################################################

MY_LIB_DIR=$( dirname "$0" ) || ( echo "ERROR $0 dirname $0"; exit 1)
MY_BASENAME=$( basename "$0" )
source "$MY_LIB_DIR/rpmrebuild_lib.src"    || ( echo "ERROR $0 source $MY_LIB_DIR/rpmrebuild_lib.src" ; exit 1)

if [ $# -ne 1 ] || [ "x$1" = "x" ]
then
	Critical "Usage: $0 <buildroot>"
fi

BuildRoot="$1"

while :; do
	read file_type
	[ "x$file_type" = "x" ] && break
	read file_flags
	read file_perm
	read file_user
	read file_group
	read file_verify
	read file_lang
	read file_cap
	read file

	[ -e "$file" ] || continue # File/directory not exist, do nothing

	case "X$file_type" in
		Xd*)
			# Directory
			# I don't use --mode for Mkdir, because it doesn't work
			# when directory already exist.

			# Permissions: see comments in the rpmrebuild_files.sh
			not_perm="${file_perm%????}"
			# Strip whatever characters we get from the start
			# of the string.
			# result will be 4 permissions characters
			file_perm="${file_perm#${not_perm}}"
			Mkdir_p "$BuildRoot/$file" || Critical "$MY_BASENAME Mkdir_p $BuildRoot/$file"
			chmod "$file_perm $BuildRoot/$file" || Critical "$MY_BASENAME chmod $file_perm $BuildRoot/$file"
		;;

		*)
			# Not directory
			DirName=${file%/*}
			Mkdir_p "$BuildRoot/$DirName" || Critical "$MY_BASENAME Mkdir_p $BuildRoot/$DirName"
			cp --preserve --no-dereference "$file" "$BuildRoot/$file" || Critical "$MY_BASENAME cp --preserve $file"
		;;
	esac || Critical "$MY_BASENAME esac"
done || Critical "$MY_BASENAME done"
exit 0
