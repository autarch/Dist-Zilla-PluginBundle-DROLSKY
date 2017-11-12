package Dist::Zilla::Plugin::DROLSKY::Git::CheckFor::CorrectBranch;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '0.87';

use Moose;

extends 'Dist::Zilla::Plugin::Git::CheckFor::CorrectBranch';

override before_release => sub {
    my $self = shift;

    return if $self->zilla->is_trial;

    super();
};

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Checks the branch on non-TRIAL releases

__END__

=for Pod::Coverage .*
