#!/usr/bin/env sh
# this script test rpmrebuild on all installed packages
# it must be started as root
# internal use for developpers
# use gnu parallel to speed up
# $Id$
# flock : https://linuxaria.com/howto/linux-shell-introduction-to-flock

# number of procs for gnu parallel
# 0 means as many as possible
maxprocs=0

# started by gnu parellel
function bench {
	pac=$1

	ladate=$( date +'%F-%H-%M-%S' )
	echo -n "$ladate build $pac "
	localoutput="${output_dir}/${pac}.output"

	# wait for rpm
	# on mageia may have : db5 erreur(-30973) de dbenv->open: BDB0087 DB_RUNRECOVERY: Fatal error, run database recovery
	max=2
	i=0
	ok=0
	while [ $i -lt $max ]
	do
		rpm -q $pac > ${localoutput} 2>&1
		if [ $? -eq 0 ]
		then
			ok=1
			break
		else
			# problem : lock to avoid several rebuild in parallel
			# first will run rebuilddb
			# other will be blocked, then test again
			lockfile=${tmpdir}/bench.lock
			exec 200>$lockfile
			flock 200 
			# test again
			rpm -q $pac > ${localoutput} 2>&1
			if [ $? -ne 0 ]
			then
				echo "rebuilddb"
				rpm -v --rebuilddb
			fi
			flock -u 200
			rm $lockfile
			let i=i+1
		fi
	done
	if [ $ok -eq 0 ]
	then
		echo "### fin $irep pb query rpm" >> ${localoutput}
	else
		localtmpdir=${tmpdir}/$$
		mkdir $localtmpdir
		nice ./rpmrebuild -b -k -y no -c yes -d $localtmpdir $pac >> ${localoutput} 2>&1 
		irep=$?
		if [ $irep -eq 0 ]
		then
			res='ok'
		else
			res='NOTOK'
			depend=$(  grep "Failed dependencies" $localoutput )
			changelog=$(  grep "changelog not in descending chronological order"  $localoutput )
			cpio=$( grep "cpio: Bad magic"  $localoutput )
			arch=$( grep "Arch dependent binaries"  $localoutput )
			notdir=$( grep "Not a directory"  $localoutput )
			db5=$( grep "run database recovery"  $localoutput )
			if [ -n "$depend" ]
			then
				res="$res (depend)"
			elif [ -n "$changelog" ]
			then
				res="$res (changelog)"
			elif [ -n "$cpio" ]
			then
				res="$res (cpio)"
			elif [ -n "$arch" ]
			then
				res="$res (arch)"
			elif [ -n "$notdir" ]
			then
				res="$res (notdir)"
			elif [ -n "$db5" ]
			then
				res="$res (db5)"
			else
				res="$res (other)"
			fi
		fi
		echo "### fin $res" >> ${localoutput}
		echo "$res"
		rm -rf $localtmpdir
	fi
}

function analyse {
	pac=$( echo $1 | sed 's/\.output//')
	output=$( cat $1 )

	let seen=seen+1
	echo -n "$seen/$max $pac "
	tst_ok=$( echo "$output" | grep '### fin ok' )
	if [ -n "$tst_ok" ]
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
			let pblog="$pblog + 1"
			list_bad_log="$list_bad_log $pac"
		elif [ -n "$cpio" ]
		then
			echo "NOTOK (cpio: Bad magic)"
			echo "  $output"
			let pbmagic="$pbmagic + 1"
			list_bad_cpio="$list_bad_cpio $pac"
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
			echo "NOTOK (db5 error)"
			echo "  $output"
			let pbdb="$pbdb + 1"
			list_bad_db="$list_bad_db $pac"
		else
			echo "KO"
			echo "  $output"
			let bad="$bad + 1"
			list_bad="$list_bad $pac"
		fi
	fi
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
if [ -f $LOG ]
then
	mv $LOG $LOG.old
fi

export tmpdir=/tmp/rpmrebuild
if [ -d $tmpdir ]
then
	echo "find $tmpdir : check if another run"
	exit 1
fi
mkdir -p $tmpdir

export output_dir="${tmpdir}/output"
mkdir $output_dir
cd $output_dir

# to have standardize error messages
export LC_ALL=POSIX
export -f bench

list=$( rpm -qa | sed 's/\.src$//' | sort )
#list="rpmrebuild
#rpmerizor"
export max=$( echo "$list" | wc -l )

echo "------- build -----------------"
echo "$list" | sort | parallel bench | tee $LOG

echo "------- analysis --------------"
# output analysis
seen=0
notok=0
bad=0
pbmagic=0
pbdep=0
pbarch=0
pbnotdir=0
pblog=0
pbdb=0
list_bad=''
list_bad_cpio=''
list_bad_dep=''
list_bad_arch=''
list_bad_dir=''
list_bad_log=''
list_bad_db=''

for f in *.output
do
	analyse $f
done

echo "-------------------------------------------------------"
echo "$notok failed build on $seen packages"
echo "  pb cpio : $pbmagic ($list_bad_cpio)"
echo "  pb dep  : $pbdep ($list_bad_dep)"
echo "  pb arch : $pbarch ($list_bad_arch)"
echo "  pb dir  : $pbnotdir ($list_bad_dir)"
echo "  pb log  : $pblog ($list_bad_log)"
echo "  pb db5  : $pbdb ($list_bad_db)"
echo "  other   : $bad ($list_bad)"
echo "full log on $LOG"
echo "-------------------------------------------------------"

# clean temporary directories
echo "clean temporary directories (o/n) ?"
read rep
if [ "$rep" == 'o' ]
then
	rm -rf $tmpdir 2> /dev/null
else
	echo "temporary directories :  $tmpdir"
fi
