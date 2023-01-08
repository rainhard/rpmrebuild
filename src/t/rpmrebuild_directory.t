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

# control
my $out = `$cmd rpmrebuild 2>&1`;
like(
	$out,
	qr/result: \/home\/.*\/rpmbuild\/RPMS\/noarch\/rpmrebuild.*noarch.rpm/,
	'directory control'
) or diag("out=$out\n");

# --directory long
$out = `$cmd --directory /tmp rpmrebuild 2>&1`;
like(
	$out,
	qr/result: \/tmp\/noarch\/rpmrebuild.*noarch.rpm/,
	'directory long'
) or diag("out=$out\n");

# -d short
$out = `$cmd -d /tmp rpmrebuild 2>&1`;
like(
	$out,
	qr/result: \/tmp\/noarch\/rpmrebuild.*noarch.rpm/,
	'directory short'
) or diag("out=$out\n");

