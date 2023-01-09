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

my $spec = "/tmp/toto_$PID.spec";

# compat_digest.plug
# add some directives in spec file
# code of rpmrebuild_compat_digest.t plugin_compat_digest.t are very likely

# 1-2 control without plugin
unlink $spec if ( -f $spec );
my $out = `$cmd --spec-only=$spec afick-doc 2>&1 `;
my $tst = -f $spec;
ok( $tst, 'md5-compat_digest build spec without' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	unlike(
		$out,
		qr/binary_filedigest_algorithm/,
		'md5-compat_digest control without'
	) or diag("out=$out\n");
}
else {
	fail('md5-compat_digest control without');
}

# 3-4 with plugin
unlink $spec if ( -f $spec );
$out = `$cmd --spec-only=$spec --md5-compat-digest afick-doc 2>&1`;
$tst = -f $spec;
ok( $tst, 'md5-compat_digest build spec with' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/binary_filedigest_algorithm/,
		'md5-compat_digest check spec'
	) or diag("out=$out\n");
}
else {
	fail('md5-compat_digest check spec');
}

# cleaning
unlink $spec if ( -f $spec );
