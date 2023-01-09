#!/usr/bin/env perl
# E Gerbier
# $Id: make_alltest.sh 2258 2011-10-19 12:23:04Z gerbier $
# start all classes/lib test
# see also  make_tests.sh

use strict;
use warnings;

## no critic (RequireConstantVersion)
our ($VERSION) = q$REVISION: 42$ =~ /(\d+)/;
## use critic

my $nb_alltests = 0;
my $nb_allok    = 0;
my $nb_allko    = 0;
my @all_failed;

sub ana_test($$) {
	my $name  = shift @_;
	my $r_tab = shift @_;

	my $nb_tests = 0, my $nb_ok = 0;
	my $nb_ko = 0;
	my @failed;
	my $debug;

	# lecture
	foreach my $line ( @{$r_tab} ) {
		if ( $line =~ m/^ok (\d+) - / ) {
			$nb_tests++;
			$nb_ok++;
		}
		elsif ( $line =~ m/^not ok (\d+) - / ) {
			my $num = $1;
			push @failed, $num;
			$nb_tests++;
			$nb_ko++;
			$debug .= "  debug : $line";
		}
	}

	# affichage
	print "$nb_ok / $nb_tests  ok ";
	if ($nb_ko) {
		print "failed $nb_ko : @failed\n";
		print $debug;
		push @all_failed, $name;
	}
	else {
		print "\n";
	}

	# stat globales
	$nb_alltests += $nb_tests;
	$nb_allok    += $nb_ok;
	$nb_allko    += $nb_ko;
	return;
}

###############################################
$ENV{'PERL5LIB'} = 'lib';
my $nb_fic    = 0;
my $class;

# allow to specify a class as a filter in argument
if ( $#ARGV == -1 ){
	# default : all tests
	print "default\n";
	$class = q{};
} else {
	$class = $ARGV[0];
	print "class : $class\n";
}
my $pattern = "t/$class*.t";
my @list_prog = glob $pattern;

# tests
foreach my $tst (@list_prog) {
	$nb_fic++;
	print "$nb_fic $tst ... ";
	## no critic (ProhibitBacktickOperators)
	my @out = ` $tst 2>&1 `;
	## use critic
	ana_test( $tst, \@out );
}

# resume
print "---------------\n";
if ($nb_allko) {
	print "WARNING : $nb_allko (sur $nb_alltests) tests failed : @all_failed\n";
}
else {
	print "OK all $nb_alltests are good (on $nb_fic files)\n";
}

