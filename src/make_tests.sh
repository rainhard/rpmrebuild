#!/usr/bin/env sh
# $Id$
# a script to start all tests
# see also make_mytest.pl

# this should be better than my own code
# but it seems to have problems with my outputs
#PERL_DL_NONLAZY=1 /usr/bin/perl "-MExtUtils::Command::MM" "-e" "test_harness(0, 'lib')" t/*.t

# cf perl best practice
if [ $# -eq 1 ]
then
	filter="t/$1*.t"
else
	filter=''
fi
prove --lib --merge $filter
