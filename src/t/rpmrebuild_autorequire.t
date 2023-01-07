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
unlink $spec if ( -f $spec );

# control
my $out = `$cmd --spec-only $spec rpmrebuild`;
like( $out, qr/specfile: $spec/, 'autorequire control build spec ok' )
  or diag("out=$out\n");
my $tst = -f $spec;
ok( $tst, 'autorequire control spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;

	unlike( $out, qr/AutoReq: yes/, 'autorequire control spec tag' )
	  or diag("out=$out\n");
}
else {
	fail('autorequire control spec');
}

# --autorequire
$out = `$cmd --autorequire --spec-only $spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'autorequire build spec ok' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'autorequire spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;

	like( $out, qr/AutoReq: yes/, 'autorequire spec tag' )
	  or diag("out=$out\n");
}
else {
	fail('autorequire spec');
}

# restore
unlink $spec if ( -f $spec );
