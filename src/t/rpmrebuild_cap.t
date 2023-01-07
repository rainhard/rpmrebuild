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
like( $out, qr/specfile: $spec/, 'cap control before build spec ok' )
  or diag("out=$out\n");
unlike(
	$out,
	qr/WARNING: some files have been modified/,
	'cap control before warning'
) or diag("out=$out\n");
unlike( $out, qr/........P  d $pb/, 'cap control before changes' )
  or diag("out=$out\n");
my $tst = -f $spec;
ok( $tst, 'cap control before spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/%doc %attr\(0644, root, root\) "$pb"/,
		'cap control before spec files'
	) or diag("out=$out\n");
}
else {
	fail('cap control before spec');
}

# modify rpmrebuild installed files
system "sudo setcap cap_setgid=ep $pb";

# 6-10 control after change
$out = `$cmd --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'cap control after build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'cap control after warning'
) or diag("out=$out\n");
like( $out, qr/........P  d $pb/, 'cap control after changes' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'cap control after spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/%doc %attr\(0644, root, root\) "$pb"/,
		'cap control after spec files'
	) or diag("out=$out\n");
}
else {
	fail('cap control after spec');
}

# 11-15 --cap-from-db (default)
$out = `$cmd --cap-from-db --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'cap cap-from-db build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'cap cap-from-db warning'
) or diag("out=$out\n");
like( $out, qr/........P  d $pb/, 'cap cap-from-db changes' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'cap cap-from-db spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/%doc %attr\(0644, root, root\) "$pb"/,
		'cap cap-from-db spec files'
	) or diag("out=$out\n");
}
else {
	fail('cap cap-from-db spec');
}

# 16-20 --cap-from-fs
$out = `$cmd --cap-from-fs --spec-only=$spec rpmrebuild 2>&1`;
like( $out, qr/specfile: $spec/, 'cap cap-from-fs build spec ok' )
  or diag("out=$out\n");
like(
	$out,
	qr/WARNING: some files have been modified/,
	'cap cap-from-fs warning'
) or diag("out=$out\n");
like( $out, qr/........P  d $pb/, 'cap cap-from-fs changes' )
  or diag("out=$out\n");
$tst = -f $spec;
ok( $tst, 'cap cap-from-fs spec exists' )
  or diag("out=$out\n");
if ($tst) {
	$out = `cat $spec`;
	like(
		$out,
		qr/%doc %attr\(0644, root, root\) %caps\(cap_setgid=ep\) "$pb"/,
		'cap cap-from-fs spec files'
	) or diag("out=$out\n");
}
else {
	fail('cap cap-from-fs spec');
}

# restore
system "sudo setcap -r $pb";
unlink $spec if ( -f $spec );
