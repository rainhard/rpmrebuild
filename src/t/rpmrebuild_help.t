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

# 1 :  no arguments
my $out = `$cmd 2>&1`;
like( $out, qr/package argument missing/, 'no parameter' )
  or diag("out=$out\n");

# 2-3 version
$out = `$cmd --version 2>&1`;
## no critic (ProhibitEscapedMetacharacters)
like( $out, qr/\d+\./, 'version' ) or diag("out=$out\n");
$out = `$cmd -V 2>&1`;
## no critic (ProhibitEscapedMetacharacters)
like( $out, qr/\d+\./, 'version' ) or diag("out=$out\n");

# 4-5 help
$out = `$cmd --help 2>&1`;
like( $out, qr/options:/, 'help' ) or diag("out=$out\n");
$out = `$cmd -h 2>&1`;
like( $out, qr/options:/, 'help' ) or diag("out=$out\n");

# 6 help-plugins
$out = `$cmd --help 2>&1`;
like( $out, qr/options:/, 'help' ) or diag("out=$out\n");

# 7 list-plugin
$out = `$cmd --list-plugin rpmrebuild 2>&1`;
like( $out, qr/demo.plug/, 'list-plugin' ) or diag("out=$out\n");

