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

# modification of rpmrebuild installed files
system 'sudo touch /usr/share/doc/rpmrebuild/*';

# control (default verify is yes)
my $out = `$cmd rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'verify control build' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'verify control output'
) or diag("out=$out\n");

# --verify yes
$out = `$cmd --verify=y rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'verify long yes build' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'verify long yes output'
) or diag("out=$out\n");

$out = `$cmd -y yes rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'verify short yes build' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'verify short yes output'
) or diag("out=$out\n");

# --verify no
$out = `$cmd --verify=n rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'verify long no build' )
  or diag("out=$out\n");
unlike(
	$out,
	qr/WARNING: some files have been modified/,
	'verify long no output'
) or diag("out=$out\n");

$out = `$cmd -y no rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'verify short no build' )
  or diag("out=$out\n");
unlike(
	$out,
	qr/WARNING: some files have been modified/,
	'verify short no output'
) or diag("out=$out\n");

# restore data
system 'sudo rpmrestore.pl -batch rpmrebuild';
