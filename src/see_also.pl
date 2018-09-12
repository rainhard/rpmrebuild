#!/usr/bin/perl
# E Gerbier 2018-09-12
# used to change links in "see also"
# produced by man2html
use strict;
use warnings;

# orig
# /man/man2html?8+rpm
# final
# rpm.8.html

# read on stdin, write on stdout

while (my $line = <STDIN>) {
	if ($line =~ m!/man/man2html\?\d\+\w+! ) {
		my @lines = split ', ', $line;
		foreach my $l2 ( @lines) {
			$l2 =~ s!/man/man2html\?(\d)\+([^"]+)!$2.$1.html!;
			print $l2 . ', ';
		}
	} else { 
		print $line;
	}
}
