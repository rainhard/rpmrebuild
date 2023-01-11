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

# set_tag.plug
# will work on Release tag

# control without plugin
my $out = `$cmd afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*-1.noarch.rpm/, 'plugin set_tag control' )
  or diag("out=$out\n");

# with plugin
# include with env
$out =
`TAG_ID=Release TAG_VAL="2test" $cmd --include $plug_dir/set_tag.plug afick-doc 2>&1 `;
like(
	$out,
	qr/result:.*afick-doc.*-2test.noarch.rpm/,
	'plugin set_tag include env'
) or diag("out=$out\n");

# call change-spec-preamble with args
$out =
`$cmd --change-spec-preamble="$plug_dir/set_tag.sh -t Release 3test" afick-doc 2>&1 `;
like(
	$out,
	qr/result:.*afick-doc.*-3test.noarch.rpm/,
	'plugin set_tag change-spec-preamble and args'
) or diag("out=$out\n");

