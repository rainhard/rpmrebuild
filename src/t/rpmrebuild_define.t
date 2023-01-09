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

# control
# ex : result: /home/eric/rpmbuild/RPMS/noarch/rpmrebuild-2.16-1.noarch.rpm
my $out = `$cmd rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild-.*-.\.noarch\.rpm/, 'control define' )
  or diag("out=$out\n");

# --define long
$out = `$cmd --define "_rpmfilename %%{NAME}.rpm" rpmrebuild 2>&1`;
like( $out, qr/result: .*rpmrebuild\.rpm/, 'define long' )
  or diag("out=$out\n");

# -D short
$out = `$cmd --define "_rpmfilename %%{NAME}.rpm" rpmrebuild 2>&1`;
like( $out, qr/result: .*rpmrebuild\.rpm/, 'define short' )
  or diag("out=$out\n");

