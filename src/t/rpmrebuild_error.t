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

# 1 bad package
my $out = `$cmd tototo 2>&1`;
like( $out, qr/is not installed/, 'no package' ) or diag("out=$out\n");

# 2 multiple package
$out = `$cmd gpg-pubkey 2>&1`;
like( $out, qr/too many packages match/, 'multiple package' )
  or diag("out=$out\n");

# 3 bad file name
$out = `$cmd -p tototo 2>&1`;
like( $out, qr/File not found/, 'no file' ) or diag("out=$out\n");

# 4 file not from package
$out = `$cmd -p $dir_src/Todo 2>&1`;
like( $out, qr/is not an rpm file/, 'not an rpm file' ) or diag("out=$out\n");

# 5 bad option
$out = `$cmd --helpe 2>&1`;
like( $out, qr/unrecognized option/, 'bad option helpe' ) or diag("out=$out\n");
$out = `$cmd -g 2>&1`;
like( $out, qr/illegal option/, 'bad option -g' ) or diag("out=$out\n");
