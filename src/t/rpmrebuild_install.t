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

# 1-3 control
my $out = `$cmd --debug rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'install control build' )
  or diag("out=$out\n");
unlike( $out, qr/DEBUG: \(Installation\)/, 'install control Installation' )
  or diag("out=$out\n");
unlike(
	$out,
qr/ERROR: \(Installation\) package 'rpmrebuild' you must be root to install package/,
	'install control error'
) or diag("out=$out\n");

# 4-6 -install long
# install fails if not root
$out = `$cmd --debug --install rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'install long build' )
  or diag("out=$out\n");
like( $out, qr/DEBUG: \(Installation\)/, 'install long Installation' )
  or diag("out=$out\n");
like(
	$out,
qr/ERROR: \(Installation\) package 'rpmrebuild' you must be root to install package/,
	'install long error'
) or diag("out=$out\n");

# 7-9 -I, install short
$out = `$cmd --debug -I rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'install short build' )
  or diag("out=$out\n");
like( $out, qr/DEBUG: \(Installation\)/, 'install short installation' )
  or diag("out=$out\n");
like(
	$out,
qr/ERROR: \(Installation\) package 'rpmrebuild' you must be root to install package/,
	'install short error'
) or diag("out=$out\n");
