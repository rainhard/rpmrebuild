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

# unset_tag.plug
# will work on arch : package is noarch, default is x86_64

# control with plugin
my $out = `$cmd afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*noarch.rpm/, 'plugin unset_tag control' )
  or diag("out=$out\n");

# with plugin
# include env
$out =
  `TAG_ID=BuildArch $cmd --include $plug_dir/unset_tag.plug afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*x86_64.rpm/, 'plugin unset_tag include' )
  or diag("out=$out\n");

# change-spec-preamble args
$out =
`$cmd --change-spec-preamble="$plug_dir/unset_tag.sh -t BuildArch " afick-doc 2>&1 `;
like(
	$out,
	qr/result:.*afick-doc.*.x86_64.rpm/,
	'plugin unset_tag change-spec-preamble args'
) or diag("out=$out\n");
