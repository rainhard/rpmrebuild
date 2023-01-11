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
## no critic (ProhibitEscapedMetacharacters)

# arguments test
$ENV{'LANG'} = 'en';
my $dir      = dirname($PROGRAM_NAME);          # the t directory
my $dir_src  = $dir . '/../';                   # the src directory
my $plug_dir = $dir_src . 'plugins';            # the plugin directory
my $cmd      = $dir_src . 'rpmrebuild.sh -b';

# un_prelink.plug
# prelink is not available on recent distributions
# as fedora 37 mageia 8

# control
my $out = `$cmd bash 2>&1 `;
like( $out, qr/result:.*bash.*\.rpm/, 'plugin un_prelink control build rpm' )
  or diag("out=$out");

# with plugin
$out = `$cmd --include $plug_dir/un_prelink.plug bash 2>&1 `;
like( $out, qr/result:.*bash.*\.rpm/, 'plugin un_prelink build rpm' )
  or diag("out=$out");
$out = `type prelink 2>&1`;
SKIP: {
	skip 'no prelink found', 1, unless $out;

	$out = `$cmd --include $plug_dir/un_prelink.plug bash 2>&1 `;

	# todo write controls
	like( $out, qr/result:.*bash.*\.rpm/, 'plugin un_prelink build rpm' )
	  or diag("out=$out");
}

