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
like( $out, qr/specfile: $spec/, 'spec_only check output' )
  or diag("out=$out\n");
ok( -e $spec, 'spec_only check file' ) or diag("out=$out\n");

# --md5-compat-digest
$out = `cat $spec`;
unlike( $out, qr/binary_filedigest_algorithm/, 'no md5-compat-digest' )
  or diag("out=$out\n");
$out = `$cmd --md5-compat-digest --spec-only=$spec rpmrebuild 2>&1`;
ok( -e $spec, 'spec_only check file' ) or diag("out=$out\n");
$out = `cat $spec`;
like( $out, qr/binary_filedigest_algorithm/, 'md5-compat-digest' )
  or diag("out=$out\n");

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
like( $out, qr/html/, 'plugin nodoc before' ) or diag("out=$out\n");
$out = `$cmd --change-spec-files="nodoc.sh " afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin nodoc call change-spec-files' )
  or diag("out=$out\n");
$out = `$cmd --include plugins/nodoc.plug afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin nodoc call include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p --docfiles $res`;
	unlike( $out, qr/html/, 'plugin nodoc check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}

# file2pacDep
$out = ` rpm -q -R afick-doc`;
unlike( $out, qr/bash/, 'plugin file2pacDep before' ) or diag("out=$out\n");
$out = `$cmd --include plugins/file2pacDep.plug afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin file2pacDep include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -R -p $res`;
	like( $out, qr/bash/, 'plugin file2pacDep check' )
	  or diag("rpm -q -R -p $res : $out\n");
}

# set_tag.plug
$out =
`TAG_ID=Release TAG_VAL="2test" $cmd --include plugins/set_tag.plug afick-doc 2>&1 `;
like(
	$out,
	qr/result:.*afick-doc.*-2test.noarch.rpm/,
	'plugin set_tag include'
) or diag("out=$out\n");
$out =
`$cmd --change-spec-preamble="plugins/set_tag.sh -t Release 3test" afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*-3test.noarch.rpm/, 'plugin set_tag.sh' )
  or diag("out=$out\n");

# unset_tag.plug
$out = `TAG_ID=BuildArch $cmd --include plugins/unset_tag.plug afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*x86_64.rpm/, 'plugin unset_tag include' )
  or diag("out=$out\n");
$out =
`$cmd --change-spec-preamble="plugins/unset_tag.sh -t BuildArch " afick-doc 2>&1 `;
like( $out, qr/result:.*afick-doc.*.x86_64.rpm/, 'plugin unset_tag.sh' )
  or diag("out=$out\n");

# uniq.plug
# pb : rpm build seems to sort the list now
# so work on builded spec file
$spec = '/tmp/toto.spec';
unlink $spec if ( -f $spec );
$out =
` $cmd --spec-only=/tmp/toto.spec -p ../build/old/rpmrebuild-1.4.6-1.noarch.rpm `;
ok( -f $spec, 'plugin uniq build spec file normal' ) or diag("out=$out\n");
my $count_requires_normal = ` grep '^Requires:' $spec | wc -l`;
chomp $count_requires_normal;
unlink $spec if ( -f $spec );
$out =
` $cmd --include plugins/uniq.plug --spec-only=/tmp/toto.spec -p ../build/old/rpmrebuild-1.4.6-1.noarch.rpm `;
ok( -f $spec, 'plugin uniq build spec file with uniq' ) or diag("out=$out\n");
my $count_requires_uniq = ` grep '^Requires:' $spec | wc -l`;
chomp $count_requires_uniq;
ok(
	$count_requires_normal != $count_requires_uniq,
"plugin uniq requires before $count_requires_normal after $count_requires_uniq"
);
unlink $spec if ( -f $spec );

# demofiles.plug
$out = ` $cmd --include plugins/demofiles.plug rpmrebuild 2>&1 `;
like( $out, qr/demofiles.plug.1rrp/, 'plugin demofiles' )
  or diag("out=$out\n");

# demo.plug
$spec = '/tmp/toto.spec';
unlink $spec if ( -f $spec );
$out = ` $cmd --spec-only=$spec --include=plugins/demo.plug rpmrebuild 2>&1 `;
like( $out, qr/specfile: $spec/, 'plugin demo check output' )
  or diag("out=$out\n");
ok( -e $spec, 'plugin demo check specfile' ) or diag("out=$out\n");
$out = ` cat $spec`;
like(
	$out,
	qr/change-spec-whole change-spec-preamble/,
	'plugin demo modified spec'
) or diag("out=$out\n");

# compat_digest.plug
unlink $spec if ( -f $spec );
$out = `$cmd --spec-only=$spec afick-doc 2>&1 `;
ok( -e $spec, 'spec_only check file' ) or diag("out=$out\n");
$out = `cat $spec`;
unlike(
	$out,
	qr/binary_filedigest_algorithm/,
	'plugin compat_digest.plug control without'
) or diag("out=$out\n");
$out =
  `$cmd --spec-only=$spec --include plugins/compat_digest.plug afick-doc 2>&1`;
ok( -e $spec, 'spec_only check file' ) or diag("out=$out\n");
$out = `cat $spec`;
like( $out, qr/binary_filedigest_algorithm/, 'plugin compat_digest.plug' )
  or diag("out=$out\n");

# un_prelink.plug
$out = `type prelink 2>&1`;
if ($out) {

	# todo but prelink is not available on recent distributions
	# fedora 37 mageia 8
	$out = `$cmd --include plugins/un_prelink.plug bash 2>&1 `;
}
else {
	diag('no prelink found : skip');
}

# exclude_file
# control
$out = ` rpm -q -l afick-doc`;
like( $out, qr/changelog/, 'plugin exclude_file control' )
	  or diag("rpm -q -l afick-doc : $out\n");
# syntaxe 1
$out = ` $cmd --change-spec-files='plugins/exclude_file.sh -r "change.og" ' afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin exclude_file regex call with option' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}
# syntaxe 2
$out = `EXCLUDE_REGEX='.hangelog' $cmd --change-spec-files='plugins/exclude_file.sh ' afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin exclude_file regex call with env' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}
# syntaxe 3
$out = `EXCLUDE_REGEX='c.angelog' $cmd --include plugins/exclude_file.plug afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin exclude_file regex include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}
# syntaxe 4
my $filter='../test/exclude_from';
$out = ` $cmd --change-spec-files='plugins/exclude_file.sh -f $filter ' afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin exclude_file from call with option' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}
# syntaxe 5
$out = `EXCLUDE_FROM=$filter $cmd --change-spec-files='plugins/exclude_file.sh ' afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin exclude_file from call with env' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}
# syntaxe 6
$out = `EXCLUDE_FROM=$filter $cmd --include plugins/exclude_file.plug afick-doc 2>&1`;
like( $out, qr/result:.*afick-doc.*rpm/, 'plugin exclude_file from include' )
  or diag("out=$out\n");
if ( $out =~ m/result:(.*afick-doc.*rpm)/ ) {
	my $res = $1;
	$out = ` rpm -q -l -p $res`;
	unlike( $out, qr/changelog/, 'plugin exclude_file check' )
	  or diag("rpm -q -l -p --docfiles $res : $out\n");
}
