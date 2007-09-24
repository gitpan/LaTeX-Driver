#========================================================================
#
# Test::LaTeX::Driver
#
# DESCRIPTION
#   Module for testing the LaTeX::Driver module
#
# AUTHOR
#   Andrew Ford <a.ford@ford-mason.co.uk>
#
# COPYRIGHT
#   Copyright (C) 2007 Andrew Ford.   All Rights Reserved.
#
#   This module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself.
#
# HISTORY
#   * New file - but portions extracted from the Template::Latex
#     module (AF, 2007-09-19)
#
#   $Id: Driver.pm 21 2007-09-23 16:21:30Z andrew $
#
# TODO
#   * finish off commenting and documentation
#
#   * integrate with Test::More
#
#========================================================================


package Test::LaTeX::Driver;

use strict;
use warnings;
use FindBin qw($Bin);
require Exporter;
use Config;

our @ISA    = qw(Exporter);
our @EXPORT = qw(get_test_params test_dvifile tidy_directory find_program dvitype);

our $WIN32  = ($^O eq 'MSWin32');

my $dvitype = find_program($ENV{PATH}, "dvitype");


sub get_test_params {
    my $basename = $0;
    $basename =~ s{ ^ .* / }{}x;
    $basename =~ s/\.t$//;
    my ($testno) = $basename =~ m/^(\d+)/;
    die "cannot determine test no from script name $0" unless $testno;
    my $basedir      = "$Bin/testdata/$basename";
    return ($testno, $basedir, $basename);
}


sub dvitype {
    return $dvitype;
}


#------------------------------------------------------------------------
# find_program($path, $prog)
#
# Find a program, $prog, by traversing the given directory path, $path.
# Returns full path if the program is found.
#
# Written by Craig Barratt, Richard Tietjen add fixes for Win32.
#
# abw changed name from studly caps findProgram() to find_program() :-)
#------------------------------------------------------------------------

sub find_program {
    my($path, $prog) = @_;

    foreach my $dir ( split($Config{path_sep}, $path) ) {
        my $file = File::Spec->catfile($dir, $prog);
        if ( !$WIN32 ) {
            return $file if ( -x $file );
        } else {
            # Windows executables end in .xxx, exe precedes .bat and .cmd
            foreach my $dx ( qw/exe bat cmd/ ) {
                return "$file.$dx" if ( -x "$file.$dx" );
            }
        }
    }

}


#------------------------------------------------------------------------
# tidy_directory($dir, $docname, $debug)
#
# Cleans up the temporary files for the document $docname in the
# directory $dir.  The temporary files are:
#
#   .aux	LaTeX auxilliary file
#   .toc	LaTeX table of contents
#   .lof	LaTeX list of figures
#   .lot	LaTeX list of tables
#   .log	LaTeX log file
#   .idx	raw index file       
#   .ibk	.idx backup file (generated by LaTeX::Driver)
#   .ind        formatted index
#   .ilg        makeindex log file
#   .cit        citation file (generated by LaTeX::Driver)
#   .cit        backup citation file (generated by LaTeX::Driver)
#   .bbl
#   .dvi
#   .ps
#   .pdf
#------------------------------------------------------------------------

sub tidy_directory {
    my ($dir, $docname, $debug) = @_;

    # Suppress undefined value warnings
    $debug = 0 unless defined($debug); 

    Test::More::diag("tidying directory '$dir'") if $debug > 1;

    die "directory $dir does not exist" unless -d $dir;
    die "filename $docname contains a directory part" if $docname =~ m!/!;

    foreach my $ext (qw(aux toc lof lot log
                        ind idx ilg ibk
                        bbl blg cit cbk
                        dvi ps pdf)) {
	my $file = File::Spec->catfile($dir, "${docname}.$ext");
	if (-e $file) {
	    Test::More::diag("removing file '$file'") if $debug > 1;
	    my $rc = unlink($file);
	    Test::More::diag("unlink returned $rc") if $debug > 2;	    
	    Test::More::diag("couldn't remove file '$file'") if $debug > 1 and -e $file;
	}
	else {
	    Test::More::diag("file '$file' does not exist") if $debug > 3;	    
	}
    }
}

sub test_dvifile {
    my $drv = shift;
    my @patterns = ref $_[0] ? @{$_[0]} : @_;
    my $file = $drv->basepath . ".dvi";
    if (! -f $file) {
	Test::More::fail("dvifile $file does not exist");
	return;
    }
    my $dvioutput =  `$dvitype $file`; 
    my $total = @patterns;
    my $found = 0;
    my $pattern = shift @patterns;
    foreach (split(/\n/, $dvioutput)) {
	next unless /^\[(.*)\]$/;
	my $string = $1;
	if ($string =~ /$pattern/) {
	    if (@patterns) {
		$pattern = shift @patterns;
		$found++;
	    }
	    else {
		Test::More::pass($drv->basename . ".dvi contains the $total patterns specified");
		return 1;
	    }
	}
    }
    Test::More::fail("pattern '$pattern' not found in " . $drv->basename . ".dvi (found $found of $total patterns)");
    return;
}

sub grep_dvi {
    my $dir = shift;
    my $file = shift;
    my $regexp = shift;
    my $path = File::Spec->catfile($dir, $file);
    return "FAIL - $file does not exist" unless -f $path;
    my $dvioutput =  `$dvitype $path`; 
    foreach (split(/\n/, $dvioutput)) {
	next unless /^\[(.*)\]$/;
	return "PASS - found '$regexp'" if /$regexp/;
    }
    return "FAIL - '$regexp' not found";
}

1;

=head1 NAME

Test::LaTeX::Driver

=head1 SYNOPSIS

=head1 DESCRIPTION


=head1 AUTHOR

Andrew Ford E<lt>a.ford@ford-mason.co.ukE<gt>


=head1 COPYRIGHT

Copyright (C) 2007 Andrew Ford.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

# Local Variables:
# mode: perl
# perl-indent-level: 4
# indent-tabs-mode: nil
# End:
#
# vim: expandtab shiftwidth=4:
