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

my $pb   = '/usr/share/doc/rpmrebuild/Todo';
my $spec = "/tmp/toto_$PID.spec";

# 1-6 control before changes
my $out = `$cmd --spec-only=$spec rpmrebuild 2>&1`;
like(
	$out,
	qr/specfile: $spec/,
	'comment-missing control before build spec ok'
) or diag("out=$out\n");
unlike(
	$out,
	qr/WARNING: some files have been modified/,
	'comment-missing control before warning'
) or diag("out=$out\n");
unlike( $out, qr/missing   d $pb/, 'comment-missing control before missing' )
  or diag("out=$out\n");
my $tst = -f $spec;
ok( $tst, 'comment-missing control before spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like( $out, qr/%doc .* "$pb"/, 'comment-missing control before spec files' )
	  or diag("out=$out\n");
	unlike(
		$out,
		qr/# MISSING: %doc .* "$pb"/,
		'comment-missing control before MISSING'
	) or diag("out=$out\n");
}
else {
	fail('comment-missing control before spec');
}

# 7 modify rpmrebuild installed files
system "sudo mv $pb $pb.sav" if ( -f $pb );
ok( !-f $pb, "comment-missing missing $pb" );

# 8-13 control after changes (default is comment-missing no)
$out = `$cmd --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'comment-missing control after build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'comment-missing control after warning'
) or diag("out=$out\n");
like( $out, qr/missing   d $pb/, 'comment-missing control after missing' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'comment-missing control after spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like( $out, qr/%doc .* "$pb"/, 'comment-missing control after spec files' )
	  or diag("out=$out\n");
	unlike(
		$out,
		qr/# MISSING: %doc .* "$pb"/,
		'comment-missing control after MISSING'
	) or diag("out=$out\n");
}
else {
	fail('comment-missing control after spec');
}

# 14-19 comment-missing no
$out = `$cmd --comment-missing=no --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'comment-missing long no build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'comment-missing long no warning'
) or diag("out=$out\n");
like( $out, qr/missing   d $pb/, 'comment-missing long no missing' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'comment-missing long no spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like( $out, qr/%doc.*$pb/, 'comment-missing long no spec files' )
	  or diag("out=$out\n");
	unlike(
		$out,
		qr/# MISSING: %doc .* "$pb"/,
		'comment-missing long no MISSING'
	) or diag("out=$out\n");
}
else {
	fail('comment-missing long no spec');
}

# 20-25 short comment-missing no
$out = `$cmd -c no --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'comment-missing short no build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'comment-missing short no warning'
) or diag("out=$out\n");
like( $out, qr/missing   d $pb/, 'comment-missing short no missing' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'comment-missing short no spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like( $out, qr/%doc.*$pb/, 'comment-missing short no spec files' )
	  or diag("out=$out\n");
	unlike(
		$out,
		qr/# MISSING: %doc .* "$pb"/,
		'comment-missing short no MISSING'
	) or diag("out=$out\n");
}
else {
	fail('comment-missing short no spec');
}

# 26-30 comment-missing long yes
$out = `$cmd --comment-missing=yes --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'comment-missing long yes build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'comment-missing long yes warning'
) or diag("out=$out\n");
like( $out, qr/missing   d $pb/, 'comment-missing long yes missing' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'comment-missing long yes spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/# MISSING: %doc .* "$pb"/,
		'comment-missing long yes spec files'
	) or diag("out=$out\n");
}
else {
	fail('comment-missing long yes spec');
}

# 31-35 comment-missing short yes
$out = `$cmd -c yes --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'comment-missing short yes build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'comment-missing short yes warning'
) or diag("out=$out\n");
like( $out, qr/missing   d $pb/, 'comment-missing short yes missing' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'comment-missing short yes spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/# MISSING: %doc .* "$pb"/,
		'comment-missing short yes spec files'
	) or diag("out=$out\n");
}
else {
	fail('comment-missing short yes spec');
}

# restore
system "sudo mv $pb.sav $pb" unless ( -f $pb );
unlink $spec if ( -f $spec );
