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

# will modify the following file and test about file size
my $file = 'usr/share/doc/rpmrebuild/Todo';

# control
my $out = `$cmd rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'modify control build' )
  or diag("out=$out\n");
my $file_size_ls = ( stat "/$file" )[7];
my $file_size_rpm =
`rpm -q --queryformat='[%{FILENAMES} %{FILESIZES}\n]' rpmrebuild | grep Todo | awk '{print \$2}' `;
ok( $file_size_ls == $file_size_rpm, 'modify control size' )
  or diag("ls=$file_size_ls rpm=$file_size_rpm");

# -m, --modify is an alias of --change-files
$out = `$cmd --modify='cd \$RPM_BUILD_ROOT && date >> $file' rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'modify long build' )
  or diag("out=$out\n");
if ( $out =~ m/result: (.*rpmrebuild.*rpm)/ ) {
	my $rpm = $1;
	$file_size_rpm =
`rpm -q -p --queryformat='[%{FILENAMES} %{FILESIZES}\n]' $rpm | grep Todo | awk '{print \$2}' `;
	ok( $file_size_ls != $file_size_rpm, 'modify long size' )
	  or diag("ls=$file_size_ls rpm=$file_size_rpm");
}
else {
	fail('modifiy long size');
}

# -m short
$out = `$cmd -m 'cd \$RPM_BUILD_ROOT && date >> $file' rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'modify short build' )
  or diag("out=$out\n");
if ( $out =~ m/result: (.*rpmrebuild.*rpm)/ ) {
	my $rpm = $1;
	$file_size_rpm =
`rpm -q -p --queryformat='[%{FILENAMES} %{FILESIZES}\n]' $rpm | grep Todo | awk '{print \$2}' `;
	ok( $file_size_ls != $file_size_rpm, 'modify short size' )
	  or diag("ls=$file_size_ls rpm=$file_size_rpm");
}
else {
	fail('modifiy short size');
}
