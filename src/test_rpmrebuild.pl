#!/usr/bin/perl
###############################################################################
#
#    Copyright (C) 2006 by Eric Gerbier
#    Bug reports to: gerbier@users.sourceforge.net
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

## no critic (ProhibitBacktickOperators)

# arguments test
$ENV{'RPMREBUILD_ROOT_DIR'} = '.';     # force use dev code
$ENV{'LANG'}                = 'en';    #
my $cmd = './rpmrebuild -b';

# 1 :  no arguments
my $out = `$cmd 2>&1`;
like( $out, qr/package argument missing/, 'no parameter' )
  or diag("out=$out\n");

# 2 version
$out = `$cmd --version 2>&1`;
## no critic (ProhibitEscapedMetacharacters)
like( $out, qr/\d+\./, 'version' ) or diag("out=$out\n");

# 3 help
$out = `$cmd --help 2>&1`;
like( $out, qr/options:/, 'help' ) or diag("out=$out\n");

# 4 bad package
$out = `$cmd tototo 2>&1`;
like( $out, qr/is not installed/, 'no package' ) or diag("out=$out\n");

# 5 multiple package
$out = `$cmd gpg-pubkey 2>&1`;
like( $out, qr/too many packages match/, 'multiple package' )
  or diag("out=$out\n");

# 6 bad file name
$out = `$cmd -p tototo 2>&1`;
like( $out, qr/File not found/, 'no file' ) or diag("out=$out\n");

# 7 file not from package
$out = `$cmd -p Todo 2>&1`;
like( $out, qr/is not an rpm file/, 'not an rpm file' ) or diag("out=$out\n");

# 8 package
$out = `$cmd afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'rpm package (afick-doc)' ) or diag("out=$out\n");

# 9 file
$out = `$cmd -p ../test/afick-doc-3.7.0-1.noarch.rpm 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'rpm file (afick-doc)' ) or diag("out=$out\n");

# 10 filesystem (user)
$out = `$cmd filesystem 2>&1`;
like( $out, qr/result:.*filesystem.*rpm/, 'filesystem (user)' ) or diag("out=$out\n");

# 11 filesystem (root)
$out = `sudo $cmd filesystem 2>&1`;
like( $out, qr/result:.*filesystem.*rpm/, 'filesystem (root)' ) or diag("out=$out\n");

# capabilities
# rpmrebuild iputils

# suggests (mandriva)
# rpmrebuild task-pulseaudio

