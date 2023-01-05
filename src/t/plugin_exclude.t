#!/usr/bin/perl
###############################################################################
#
#    Copyright (C) 2023 by Eric Gerbier
#    Bug reports to: eric.gerbier@tutanota.com
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
# automatic test of rpmrerebuild software

use strict;
use warnings;
use Test::More qw(no_plan);
use Data::Dumper;
use File::Basename;
use English qw(-no_match_vars);

## no critic (ProhibitBacktickOperators)

# arguments test
$ENV{'LANG'} = 'en';
my $dir      = dirname($PROGRAM_NAME);          # the t directory
my $dir_src  = $dir . '/../';                   # the src directory
my $plug_dir = $dir_src . 'plugins';            # the plugin directory
my $cmd      = $dir_src . 'rpmrebuild.sh -b';

my $filter = $dir_src . '../test/exclude_from';
ok( -f $filter, 'plugin exclude_file check if exclude_from file exists' );

# exclude_file
# exclude files from spec with regex online or from a file
# will work on changelog files

# 2 control
my $out = `rpm -q -l afick-doc`;
like( $out, qr/changelog/, 'plugin exclude_file control' )
  or diag("rpm -q -l afick-doc : $out\n");

# 3-4 syntaxe 1 : short online regex change-spec-files
$out =
` $cmd --change-spec-files="$plug_dir/exclude_file.sh -r 'change.og' " afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/,
	'plugin exclude_file regex call with short option' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 5-6 syntaxe 1 : long online regex change-spec-files
$out =
` $cmd --change-spec-files="$plug_dir/exclude_file.sh --regex 'change.og' " afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/,
	'plugin exclude_file regex call with long option' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 7-8 syntaxe 2 : env regex change-spec-files
$out =
`EXCLUDE_REGEX='.hangelog' $cmd --change-spec-files="$plug_dir/exclude_file.sh " afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/,
	'plugin exclude_file regex call with env' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 9-10 syntaxe 3 : env regex include
$out =
`EXCLUDE_REGEX='c.angelog' $cmd --include $plug_dir/exclude_file.plug afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin exclude_file regex include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 11-12 syntaxe 4 : from_file short online change-spec-files
$out =
` $cmd --change-spec-files="$plug_dir/exclude_file.sh -f $filter " afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/,
	'plugin exclude_file from call with short option' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 13-14 syntaxe 4 : from_file long online change-spec-files
$out =
` $cmd --change-spec-files="$plug_dir/exclude_file.sh --from $filter " afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/,
	'plugin exclude_file from call with long option' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 15-16 syntaxe 5 : from_file env change-spec-files
$out =
`EXCLUDE_FROM=$filter $cmd --change-spec-files="$plug_dir/exclude_file.sh " afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/,
	'plugin exclude_file from call with env' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 17-18 syntaxe 6 : from_file env include
$out =
`EXCLUDE_FROM=$filter $cmd --include $plug_dir/exclude_file.plug afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin exclude_file from include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}
