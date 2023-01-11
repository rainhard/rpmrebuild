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

my $spec    = "/tmp/toto_$PID.spec";
my $rpmfile = $dir_src . '../build/old/rpmrebuild-1.4.6-1.noarch.rpm';

# uniq.plug
# pb : rpm build seems to sort the list now
# so work on builded spec file

# control without plugin
unlink $spec if ( -f $spec );
my $out = `$cmd --spec-only=$spec -p $rpmfile `;
ok( -f $spec, 'plugin uniq build spec file normal' ) or diag("out=$out\n");
my $count_requires_normal = `grep '^Requires:' $spec | wc -l`;
chomp $count_requires_normal;

# with plugin
unlink $spec if ( -f $spec );
$out = ` $cmd --include $plug_dir/uniq.plug --spec-only=$spec -p $rpmfile`;
ok( -f $spec, 'plugin uniq build spec file with uniq' ) or diag("out=$out\n");
my $count_requires_uniq = `grep '^Requires:' $spec | wc -l`;
chomp $count_requires_uniq;
ok(
	$count_requires_normal != $count_requires_uniq,
"plugin uniq requires before $count_requires_normal after $count_requires_uniq"
);

# cleaning
unlink $spec if ( -f $spec );
