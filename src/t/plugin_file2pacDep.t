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

# file2pacDep
# change file require to package dependencies
# on afick-doc convert /bin/sh to bash

# 1-2 control without plugin
my $out = `rpm -q -R afick-doc`;
like( $out, qr/\/bin\/sh/, 'plugin file2pacDep control /bin/sh' )
  or diag("out=$out\n");
unlike( $out, qr/bash/, 'plugin file2pacDep control bash' )
  or diag("out=$out\n");

# 3-4 with plugin
$out = `$cmd --include $plug_dir/file2pacDep.plug afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin file2pacDep include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = `rpm -q -R -p $res`;

	# /bin/sh is already used by preinstall scriptlet
	#unlike( $out, qr/\/bin\/sh/, 'plugin file2pacDep check /bin/sh' )
	#  or diag("out=$out\n");
	like( $out, qr/bash/, 'plugin file2pacDep check bash' )
	  or diag("rpm -q -R -p $res : $out\n");
}

