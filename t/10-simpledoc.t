#!/usr/bin/perl
# $Id: 10-simpledoc.t 13 2007-09-21 22:56:47Z andrew $

use strict;
use blib;
use FindBin qw($Bin);
use File::Spec;
use lib ("$Bin/../lib", "$Bin/lib");
use Data::Dumper;

use Test::More tests => 10;

use Test::LaTeX::Driver;
use LaTeX::Driver;

# Debug configuration
my $debug        = 0;
my $dont_tidy_up = 0;

# Get the test configuration
my ($testno, $basedir, $docname) = get_test_params();

tidy_directory($basedir, $docname, $debug);

my $drv = LaTeX::Driver->new( basedir     => $basedir,
			      basename    => $docname,
			      DEBUG       => $debug,
			      DEBUGPREFIX => '# [latex]: ' );

diag("Checking the formatting of a simple LaTeX document");
isa_ok($drv, 'LaTeX::Driver');
is($drv->basedir, $basedir, "checking basedir");
is($drv->basename, $docname, "checking basename");
is($drv->basepath, File::Spec->catpath('', $basedir, $docname), "checking basepath");
is($drv->formatter, 'latex', "formatter");

ok($drv->run, "formatting $docname");

is($drv->stats->{formatter_runs}, 1, "should have run latex once");
is($drv->stats->{bibtex_runs},    0, "should not have run bibtex");
is($drv->stats->{makeindex_runs}, 0, "should not have run makeindex");


test_dvifile($drv, [ "Simple Test Document $testno",	# title
		     'A.N. Other',			# author
		     '20 September 2007',		# date
		     'This is a test document with a single line of text.' ] );

tidy_directory($basedir, $docname, $debug)
    unless $dont_tidy_up;

exit(0);