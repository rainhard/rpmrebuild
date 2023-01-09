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

my $pb   = '/usr/share/doc/rpmrebuild/Todo';
my $spec = "/tmp/toto_$PID.spec";

# 1-5 control before changes
my $out = `$cmd --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'pug control before build spec ok' )
  or diag("out=$out\n");
unlike(
	$out,
	qr/WARNING: some files have been modified/,
	'pug control before warning'
) or diag("out=$out\n");
unlike( $out, qr/.....UG..  d $pb/, 'pug control before changes' )
  or diag("out=$out\n");
my $tst = -f $spec;
ok( $tst, 'pug control before spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/%doc %attr\(0644, root, root\) "$pb"/,
		'pug control before spec files'
	) or diag("out=$out\n");
}
else {
	fail('pug control before spec');
}

# modify rpmrebuild installed files
system "sudo chown eric:eric $pb";

# 6-10 control after change
$out = `$cmd --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'pug control after build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'pug control after warning'
) or diag("out=$out\n");
like( $out, qr/.....UG..  d $pb/, 'pug control after changes' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'pug control after spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/%doc %attr\(0644, root, root\) "$pb"/,
		'pug control after spec files'
	) or diag("out=$out\n");
}
else {
	fail('pug control after spec');
}

# 11-15 pug-from-db (default)
$out = `$cmd --pug-from-db --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'pug pug-from-db build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'pug pug-from-db warning'
) or diag("out=$out\n");
like( $out, qr/.....UG..  d $pb/, 'pug pug-from-db changes' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'pug pug-from-db spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/%doc %attr\(0644, root, root\) "$pb"/,
		'pug pug-from-db spec files'
	) or diag("out=$out\n");
}
else {
	fail('pug pug-from-db spec');
}

# 16-20 pug-from-fs
$out = `$cmd --pug-from-fs --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'pug pug-from-fs build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'pug pug-from-fs warning'
) or diag("out=$out\n");
like( $out, qr/.....UG..  d $pb/, 'pug pug-from-fs changes' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'pug pug-from-fs spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	unlike(
		$out,
		qr/%doc %attr\(0644, root, root\) "$pb"/,
		'pug pug-from-fs spec files'
	) or diag("out=$out\n");
}
else {
	fail('pug pug-from-fs spec');
}

# 21-25 keep-perm alias of pug-from-fs
$out = `$cmd --keep-perm --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'pug keep-perm build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'pug keep-perm warning'
) or diag("out=$out\n");
like( $out, qr/.....UG..  d $pb/, 'pug keep-perm changes' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'pug keep-perm spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	unlike(
		$out,
		qr/%doc %attr\(0644, root, root\) "$pb"/,
		'pug keep-perm spec files'
	) or diag("out=$out\n");
}
else {
	fail('pug keep-perm spec');
}

# 26-30 -k of pug-from-fs
$out = `$cmd -k --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'pug short keep-perm build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'pug short keep-perm warning'
) or diag("out=$out\n");
like( $out, qr/.....UG..  d $pb/, 'pug short keep-perm changes' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'pug short keep-perm spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	unlike(
		$out,
		qr/%doc %attr\(0644, root, root\) "$pb"/,
		'pug short keep-perm spec files'
	) or diag("out=$out\n");
}
else {
	fail('pug short keep-perm spec');
}

# restore
system "sudo chown root:root $pb";
unlink $spec if ( -f $spec );
