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

# warning is used to detect meta-car (*?) in files

# control
my $out = `$cmd rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'warning control build' )
  or diag("out=$out\n");
$out = `$cmd --debug rpmrebuild 2>&1`;
like( $out, qr/RPMREBUILD_WARNING=no/, 'warning control env' )
  or diag("out=$out\n");
$out = `$cmd --package $dir_src/../test/toto-0.1-1.x86_64.rpm  2>&1`;
unlike( $out, qr/contains globbing characters/, 'warning control output' )
  or diag("out=$out\n");

# --warning
$out = `$cmd --warning rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'warning long build' )
  or diag("out=$out\n");
$out = `$cmd --debug --warning rpmrebuild 2>&1`;
like( $out, qr/RPMREBUILD_WARNING=yes/, 'warning long env' )
  or diag("out=$out\n");
$out = `$cmd --warning --package $dir_src/../test/toto-0.1-1.x86_64.rpm  2>&1`;
like( $out, qr/contains globbing characters/, 'warning long output' )
  or diag("out=$out\n");

# -w
$out = `$cmd -w rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'warning short build' )
  or diag("out=$out\n");
$out = `$cmd --debug -w rpmrebuild 2>&1`;
like( $out, qr/RPMREBUILD_WARNING=yes/, 'warning short env' )
  or diag("out=$out\n");
$out = `$cmd -w --package $dir_src/../test/toto-0.1-1.x86_64.rpm  2>&1`;
like( $out, qr/contains globbing characters/, 'warning short output' )
  or diag("out=$out\n");
