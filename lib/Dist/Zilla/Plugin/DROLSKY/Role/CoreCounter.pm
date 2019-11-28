package Dist::Zilla::Plugin::DROLSKY::Role::CoreCounter;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '1.04';

use File::Which qw( which );

use Moose::Role;

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _core_count {
    my $nproc = which('nproc');
    return 2 unless $nproc;

    ## no critic (InputOutput::ProhibitBacktickOperators)
    my $count = `$nproc`;
    return 2 unless defined $count;

    $count =~ s/^\s+|\s+$//g;

    return $count * 2;
}

1;

# ABSTRACT: Knows how to count cores (on Linux only for now)

__END__

=for Pod::Coverage .*
