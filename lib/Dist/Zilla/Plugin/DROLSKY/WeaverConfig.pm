package Dist::Zilla::Plugin::DROLSKY::WeaverConfig;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '1.12';

use Moose;

with 'Dist::Zilla::Role::Plugin';

has include_donations_pod => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
);

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: A plugin that exists solely to hold Pod::Weaver config

__END__

=for Pod::Coverage .*
