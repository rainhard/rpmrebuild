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

# 1 installed package
my $out = `$cmd afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'rpm package (afick-doc)' )
  or diag("out=$out\n");

# 2-3 rpm file
$out = `$cmd -p $dir_src/../test/afick-doc-3.7.0-1.noarch.rpm 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'rpm file short (afick-doc)' )
  or diag("out=$out\n");
$out = `$cmd --package $dir_src/../test/afick-doc-3.7.0-1.noarch.rpm 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'rpm file long (afick-doc)' )
  or diag("out=$out\n");

# works on mageia, not on fedora because filesystem contains /proc
# 4 filesystem (user)
#$out = `$cmd filesystem 2>&1`;
#like( $out, qr/result:.*filesystem.*rpm/, 'filesystem (user)' )
#  or diag("out=$out\n");

# 5 filesystem (root)
#$out = `sudo $cmd filesystem 2>&1`;
#like( $out, qr/result:.*filesystem.*rpm/, 'filesystem (root)' )
#  or diag("out=$out\n");

