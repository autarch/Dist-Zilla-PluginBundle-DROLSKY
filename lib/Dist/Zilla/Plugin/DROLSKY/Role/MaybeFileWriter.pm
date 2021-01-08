package Dist::Zilla::Plugin::DROLSKY::Role::MaybeFileWriter;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '1.12';

use Path::Tiny qw( path );

use Moose::Role;

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _maybe_write_file {
    my $self          = shift;
    my $path          = shift;
    my $content       = shift;
    my $is_executable = shift;

    my $file = path($path);

    return if $file->exists;

    ## no critic (ValuesAndExpressions::ProhibitLeadingZeros )
    $file->parent->mkpath( 0, 0755 );
    $file->spew_utf8($content);
    $file->chmod(0755) if $is_executable;

    return;
}

1;

# ABSTRACT: Knows how to maybe write files

__END__

=for Pod::Coverage .*
