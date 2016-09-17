package Dist::Zilla::Plugin::DROLSKY::VersionProvider;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '0.71';

use Parse::PMFile;

use Moose;

with 'Dist::Zilla::Role::VersionProvider';

sub provide_version {
    my $self = shift;

    ( my $module = $self->zilla->name ) =~ s{-}{/}g;
    my $file = "lib/$module.pm";
    $self->log_fatal("Cannot find $file to get \$VERSION from")
        unless -e $file;

    my ( $info, undef ) = Parse::PMFile->new->parse($file);
    ( my $package = $self->zilla->name ) =~ s/-/::/g;
    unless ( $info->{$package}{version} ) {
        $self->log_fatal(
            "Parse::PMFile could not find a \$VERSION for $package in $file");
    }

    return $info->{$package}{version};
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Gets the distribution version from the main module's $VERSION

__END__

=for Pod::Coverage .*
