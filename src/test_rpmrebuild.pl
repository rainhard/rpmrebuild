#!/usr/bin/perl
###############################################################################
#
#    Copyright (C) 2006 by Eric Gerbier
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

## no critic (ProhibitBacktickOperators)

# arguments test
$ENV{'RPMREBUILD_ROOT_DIR'} = q{.};    # force use dev code
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
like( $out, qr/result:.*afick-doc.*rpm/, 'rpm package (afick-doc)' )
  or diag("out=$out\n");

# 9 file
$out = `$cmd -p ../test/afick-doc-3.7.0-1.noarch.rpm 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'rpm file (afick-doc)' )
  or diag("out=$out\n");

# 10 filesystem (user)
$out = `$cmd filesystem 2>&1`;
like( $out, qr/result:.*filesystem.*rpm/, 'filesystem (user)' )
  or diag("out=$out\n");

# 11 filesystem (root)
# works on mageia, not on fedora because filesystem contains /proc
$out = `sudo $cmd filesystem 2>&1`;
like( $out, qr/result:.*filesystem.*rpm/, 'filesystem (root)' )
  or diag("out=$out\n");

# --cap-from-fs
$out = `$cmd --cap-from-fs rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'cap-from-fs' ) or diag("out=$out\n");

# --cap-from-db
$out = `$cmd --cap-from-db rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'cap-from-db' ) or diag("out=$out\n");

# --comment-missing
$out = `$cmd --comment-missing=yes rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'comment-missing yes' )
  or diag("out=$out\n");
$out = `$cmd --comment-missing=no rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'comment-missing no' )
  or diag("out=$out\n");

# --notest-install
$out = `$cmd --notest-install rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'notest-install' )
  or diag("out=$out\n");

# --pug-from-db
$out = `$cmd --pug-from-db rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'pug-from-db' ) or diag("out=$out\n");

# --pug-from-fs
$out = `$cmd --pug-from-fs rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'pug-from-fs' ) or diag("out=$out\n");

# --autoprovide
$out = `$cmd --autoprovide rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'autoprovide' ) or diag("out=$out\n");

# --autorequire
$out = `$cmd --autorequire rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'autorequire' ) or diag("out=$out\n");

# --release
$out = `$cmd --release=test rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'release' ) or diag("out=$out\n");

# --debug
$out = `$cmd --debug rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'debug' ) or diag("out=$out\n");

# --verify
$out = `$cmd --verify=y rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'verify yes' ) or diag("out=$out\n");
$out = `$cmd --verify=n rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'verify no' ) or diag("out=$out\n");

# --list-plugin
$out = `$cmd --list-plugin rpmrebuild 2>&1`;
like( $out, qr/demo.plug/, 'list-plugin' ) or diag("out=$out\n");

# --warning
$out = `$cmd --warning rpmrebuild 2>&1`;
like( $out, qr/result:.*rpmrebuild.*rpm/, 'warning' ) or diag("out=$out\n");

# --spec-only
my $spec = '/tmp/rpmrebuild.spec';
unlink $spec if ( -e $spec );
$out = `$cmd --spec-only=$spec rpmrebuild 2>&1`;
ok( -e $spec, 'spec_only' ) or diag("out=$out\n");

# capabilities
# shadow-utils (mageia 8)
# /usr/bin/newgidmap cap_setgid=ep
# /usr/bin/newuidmap cap_setuid=ep
# rpmrebuild iputils ?

# suggests (mandriva)
# rpmrebuild task-pulseaudio

# plugins
#########

# nodoc
$out = ` rpm -q -l --docfiles afick-doc`;
like ( $out, qr/html/, 'before nodoc') or diag("out=$out\n");
$out = `$cmd --change-spec-files="nodoc.sh " afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin nodoc' )
  or diag("out=$out\n");
$out = `$cmd --include plugins/nodoc.plug afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin nodoc include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/) {
	my $res = $1;
	$out = ` rpm -q -l -p --docfiles $res`;
	unlike ( $out, qr/html/, 'check nodoc') or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# file2pacDep
$out = ` rpm -q -R afick-doc`;
unlike ( $out, qr/bash/, 'before file2pacDep') or diag("out=$out\n");
$out = `$cmd --include plugins/file2pacDep.plug afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin file2pacDep include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/) {
	my $res = $1;
	$out = ` rpm -q -R -p $res`;
	like ( $out, qr/bash/, 'check file2pacDep') or diag("rpm -q -R -p $res : $out\n");
}

# compat_digest.plug
$out = `$cmd --include plugins/compat_digest.plug afick-doc 2>&1 `;
#like( $out, qr/result:.*afick-doc.*rpm/, 'plugin compat_digest.plug include' )
#  or diag("out=$out\n");

# uniq.plug

# set_tag.plug
$out = `TAG_ID=Release TAG_VAL="2test" $cmd --include plugins/set_tag.plug afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*-2test.noarch.rpm/, 'plugin set_tag include' )
  or diag("out=$out\n");
$out = `$cmd --change-spec-preamble="plugins/set_tag.sh -t Release 3test" afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*-3test.noarch.rpm/, 'plugin set_tag.sh' )
  or diag("out=$out\n");

# unset_tag.plug

# un_prelink.plug
