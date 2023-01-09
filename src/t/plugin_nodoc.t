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

# nodoc

# 1-2 control without plugin
my $out = `rpm -q -l --docfiles rpmrebuild`;
like( $out, qr/LISEZ.MOI/, 'plugin nodoc control doc' ) or diag("out=$out\n");
like( $out, qr/man/,       'plugin nodoc control man' ) or diag("out=$out\n");

# with plugin
# 3-5 syntaxe include
$out = `$cmd --include $plug_dir/nodoc.plug rpmrebuild 2>&1 `;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'plugin nodoc call include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*rpmrebuild.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p --docfiles $res`;
	unlike( $out, qr/LISEZ.MOI/, 'plugin nodoc include check doc' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
	unlike( $out, qr/man/, 'plugin nodoc include check man' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 6-8 syntaxe change-spec-files
$out = `$cmd --change-spec-files="$plug_dir/nodoc.sh" rpmrebuild 2>&1 `;
like( $out, qr/result:.*rpmrebuild.*rpm/,
	'plugin nodoc call change-spec-files' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*rpmrebuild.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p --docfiles $res`;
	unlike( $out, qr/LISEZ.MOI/, 'plugin nodoc change-spec-files check doc' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
	unlike( $out, qr/man/, 'plugin nodoc change-spec-files check man' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 9-11 syntaxe change-spec-files -m
$out = `$cmd --change-spec-files="$plug_dir/nodoc.sh -m" rpmrebuild 2>&1 `;
like( $out, qr/result:.*rpmrebuild.*rpm/,
	'plugin nodoc call change-spec-files -m' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*rpmrebuild.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p --docfiles $res`;
	like( $out, qr/LISEZ.MOI/, 'plugin nodoc change-spec-files check doc' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
	unlike( $out, qr/man/, 'plugin nodoc change-spec-files check man' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 12-14 syntaxe change-spec-files --man
$out = `$cmd --change-spec-files="$plug_dir/nodoc.sh --man" rpmrebuild 2>&1 `;
like( $out, qr/result:.*rpmrebuild.*rpm/,
	'plugin nodoc call change-spec-files --man' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*rpmrebuild.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p --docfiles $res`;
	like( $out, qr/LISEZ.MOI/, 'plugin nodoc change-spec-files check doc' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
	unlike( $out, qr/man/, 'plugin nodoc change-spec-files check man' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 15-17 syntaxe change-spec-files -d
$out = `$cmd --change-spec-files="$plug_dir/nodoc.sh -d" rpmrebuild 2>&1 `;
like( $out, qr/result:.*rpmrebuild.*rpm/,
	'plugin nodoc call change-spec-files -d' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*rpmrebuild.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p --docfiles $res`;
	unlike( $out, qr/LISEZ.MOI/, 'plugin nodoc change-spec-files check doc' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
	like( $out, qr/man/, 'plugin nodoc change-spec-files check man' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# 18-20 syntaxe change-spec-files --doc
$out = `$cmd --change-spec-files="$plug_dir/nodoc.sh --doc" rpmrebuild 2>&1 `;
like( $out, qr/result:.*rpmrebuild.*rpm/,
	'plugin nodoc call change-spec-files --doc' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*rpmrebuild.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p --docfiles $res`;
	unlike( $out, qr/LISEZ.MOI/, 'plugin nodoc change-spec-files check doc' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
	like( $out, qr/man/, 'plugin nodoc change-spec-files check man' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}
