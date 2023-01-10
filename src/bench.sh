#!/usr/bin/env bash
# this script test rpmrebuild on all installed packages
# it must be started as root
# internal use for developpers
# $Id$

# shellcheck disable=SC2219
# shellcheck disable=SC2181

function bench {
	# rpm -qa can return packages as gpg-pubkey-4ebfc273-48b5dbf3.src
	list=$( rpm -qa | sed 's/\.src$//' | sort )
	max=$( echo "$list" | wc -l )

	seen=0
	notok=0
	bad=0
	pbmagic=0
	pbdep=0
	pbarch=0
	pbnotdir=0
	pbchangelog=0
	pbdb5=0
	pbglob=0
	list_bad=''
	list_bad_dep=''
	list_bad_magic=''
	list_bad_arch=''
	list_bad_dir=''
	list_bad_changelog=''
	list_bad_db5=''
	list_bad_glob=''

	for pac in $list
	do
		let seen="$seen + 1"
		echo -n "$seen/$max $pac "
		localtmpdir=${tmpdir}/$$
		mkdir $localtmpdir
		output=$( nice ./rpmrebuild.sh -b -k -w -y no -c yes -d $localtmpdir $pac  2>&1 )
		irep=$?
		if [ $irep -eq 0 ]
		then
			echo "ok"
		else

			# parse output to remove false problems
			# dependencies problem ...
			# and only keep real rpmrebuild errors
			# todo : pubkey ?
			let notok="$notok + 1"

			depend=$( echo "$output" | grep "Failed dependencies" )
			changelog=$( echo "$output" | grep "changelog not in descending chronological order" )
			cpio=$( echo "$output" | grep "cpio: Bad magic" )
			arch=$( echo "$output" | grep "Arch dependent binaries" )
			notdir=$( echo "$output" | grep "Not a directory" )
			db5=$( echo "$output" | grep "run database recovery" )
			glob=$( echo "$output" | grep "contains globbing characters" )
			if [ -n "$depend" ]
			then
				echo "NOTOK (Failed dependencies)"
				echo "  $output"
				let pbdep="$pbdep + 1"
				list_bad_dep="$list_bad_dep $pac"
			elif [ -n "$changelog" ]
			then
				echo "NOTOK (changelog not in descending chronological order)"
				echo "  $output"
				let pbchangelog="$pbchangelog + 1"
				list_bad_changelog="$list_bad_changelog $pac"
			elif [ -n "$cpio" ]
			then
				echo "NOTOK (cpio: Bad magic)"
				echo "  $output"
				let pbmagic="$pbmagic + 1"
				list_bad_magic="$list_bad_magic $pac"
			elif [ -n "$arch" ]
			then
				echo "NOTOK (Arch dependent binaries)"
				echo "  $output"
				let pbarch="$pbarch + 1"
				list_bad_arch="$list_bad_arch $pac"
			elif [ -n "$notdir" ]
			then
				echo "NOTOK (Not a directory)"
				echo "  $output"
				let pbnotdir="$pbnotdir + 1"
				list_bad_dir="$list_bad_dir $pac"
			elif [ -n "$db5" ]
			then
				echo "NOTOK (db5)"
				echo "  $output"
				let pbdb5="$pbdb5 + 1"
				list_bad_db5="$list_bad_db5 $pac"
			elif [ -n "$glob" ]
			then
				echo "NOTOK (glob)"
				echo "  $output"
				let pbglob="$pbglob + 1"
				list_bad_glob="$list_bad_glob $pac"
			else
				echo "KO"
				echo "  $output"
				let bad="$bad + 1"
				list_bad="$list_bad $pac"
			fi
		fi

		# remove new rpm files to avoid file system full
		rm -rf $localtmpdir
	done

	echo "-------------------------------------------------------"
	echo "$notok failed build on $seen packages"
	echo "  pb cpio : $pbmagic ($list_bad_magic)"
	echo "  pb dep  : $pbdep ($list_bad_dep)"
	echo "  pb arch : $pbarch ($list_bad_arch)"
	echo "  pb dir  : $pbnotdir ($list_bad_dir)"
	echo "  pb changelog  : $pbchangelog ($list_bad_changelog)"
	echo "  pb db5  : $pbdb5 ($list_bad_db5)"
	echo "  pb glob : $pbglob ($list_bad_glob)"
	echo "  others  : $bad ($list_bad)"
	echo "full log on $LOG"
	echo "-------------------------------------------------------"
}

############################################################
# main
############################################################

# check root
ID=$( id -u )
if [ "$ID" -ne 0 ]
then
	echo "should run as root"
	exit 1
fi

LOG="$(pwd)/rpmrebuild_bench.log"
if [ -f "$LOG" ]
then
	mv "$LOG" "${LOG}.old"
fi

export tmpdir=/tmp/rpmrebuild
if [ -d "$tmpdir" ]
then
	echo "find $tmpdir : check if another run"
	exit 1
fi
mkdir -p $tmpdir

# to have standardize error messages
export LC_ALL=POSIX

bench 2>&1 | tee $LOG

# temporary directories
if [ -z "$1" ]
then
	# by default clean
	echo "clean temporary directories :  $tmpdir"
	rm -rf $tmpdir 2> /dev/null
else
	echo "keep temporary directories :  $tmpdir"
fi
