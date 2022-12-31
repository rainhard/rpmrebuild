#!/usr/bin/env bash
###############################################################################
#   exclude_file.sh
#      it's a part of the rpmrebuild project
#
#    Copyright (C) 2023 by Eric Gerbier
#    Bug reports to: eric.gerbier@tutanota.com
#      or	   : valery_reznic@users.sourceforge.net
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
# code's file of exclude_file plugin for rpmrebuild

version=1.0
debug=''

###############################################################################
function msg () {
	echo >&2 "$*"
}
###############################################################################
function debug () {
	if [ -n "$debug" ]
	then
		msg "debug $*"
	fi
}
###############################################################################
function syntaxe () {
	msg "this plugin files from package"
	msg "it must be called with : rpmrebuild --change-spec-files"
	msg "-f|--from : take list from a file"
	msg "-r|--regex : use given regex"
	msg "-h|--help : this help"
	msg "-v|--version : print plugin version"
	msg "-d|--debug : print debug messages"
	msg "without option, do nothing"
	exit 1

}
###############################################################################
function check_file () {
	local f=$1
	if [ ! -f "$f" ]
	then
		msg "file $f not found"
		exit 1
	elif [ ! -r "$f" ]
	then
		msg "can not read file $f"
		exit 1
	else
		# read file
		EXCLUDE_LIST=$( < "$f" )
		# change \n into space
		# shellcheck disable=SC2086
		# shellcheck disable=SC2116
		EXCLUDE_LIST2=$( echo $EXCLUDE_LIST )
		EXCLUDE_REGEX=${EXCLUDE_LIST2// /\|}
		debug "EXCLUDE_REGEX=$EXCLUDE_REGEX"
	fi

}
###############################################################################
function filter_file () {
	local f=$1

	local tst
	tst=$(echo "$f" | grep -E "$EXCLUDE_REGEX" )
	if [ -n "$tst" ]
	then
		# found pattern : skip
		skip=y
		debug "(filter_file) $f skip=y"
	else
		skip=''
	fi
}
###############################################################################

# test for arguments
if [ $# -ne 0 ]
then
	while [[ -n "$1" ]]
	do
		case $1 in
			-d | --debug )
				debug=y
				shift
				;;
			-h | --help )
				syntaxe
				;;

			-f | --from )
				shift
				EXCLUDE_FROM=$1
				# check if file exists
				check_file "$EXCLUDE_FROM"
				shift
				;;

			-r | --regex )
				shift
				EXCLUDE_REGEX=$1
				shift
				;;

			-v | --version )
				msg "$0 version $version";
				exit 1;
				;;

			*)
				msg "bad option : $1";
				syntaxe
				;;
		esac
	done
elif [ -n "$EXCLUDE_FROM" ]
then
	# we can also provide value by environment
	check_file "$EXCLUDE_FROM"
elif [ -n "$EXCLUDE_REGEX" ]
then
	# we can also provide value by environment
	echo ''
else
	msg "no options, no env variables"
	syntaxe
fi

# test the way to be called
# shellcheck disable=SC2154
if [ "$LONG_OPTION" != "change-spec-files" ]
then
	msg "error : $0 can not be called by $LONG_OPTION"
	syntaxe
	exit 1
fi

while read -r line
do
	skip=''
	# format
	# %defattr(-,root,root)
	# %dir /usr/lib/rpmrebuild
	# /usr/lib/rpmrebuild/optional_tags.cfg
	# %dir %attr(0555, root, root) "/afs"
	case "$line" in
		'#'*)
			# comment
			skip=''
			;;
		%defattr*)
			# no file name
			skip=''
			;;
		*)
			# file is the last elem of the line
			thefile=$( echo "$line" | awk -F ' ' '{print $NF}' | sed 's/"//g' )
			filter_file "$thefile"
			;;
	esac
	if [ -z "$skip" ]
	then
		echo "$line"
	fi
done
