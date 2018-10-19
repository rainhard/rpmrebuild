#!/bin/sh
# E Gerbier
# convert man page into html page

src=$1
dest=$2

if [ -z "$dest" ]
then
	echo "syntaxe : $0 source dest"
	exit
fi

if [ -f $src ] 
then
	# verification du type man
	tst=$( file $src | egrep "ASCII|troff" )
	if [ -n "$tst" ]
	then
		echo "--------------- $src => $dest -------------------------"

		echo '<?xml version="1.0" encoding="utf-8"?' > $dest
		# man en html
		#man2html $src | grep -v "Content-type:" | grep -v "Return to Main Contents" | sed -e 's!http://localhost/cgi-bin/man/man2html!!g' -e 's!/man/man2html!!g' -e 's!\?[1-8]+!!g' -e 's!<A HREF="">man2html</A>!man2html!g' -e 's/<DL COMPACT>/<DL>/g'    >> $dest
		man2html $src | grep -v "Content-type:" | grep -v "Return to Main Contents" | sed -e 's/<DL COMPACT>/<DL>/g' | ./see_also.pl >> $dest

		# html strict
		html2xhtml $dest

		# menage
		rm $dest.old
	else
		echo "$src not in man format"
	fi
else
	echo "(faire_doc2) $src non trouve"
fi
