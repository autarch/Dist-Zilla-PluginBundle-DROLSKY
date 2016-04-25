package Dist::Zilla::Plugin::DROLSKY::CheckChangesHasContent;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '0.50';

use CPAN::Changes;

use Moose;

with 'Dist::Zilla::Role::BeforeRelease';

sub before_release {
    my $self = shift;

    $self->log('Checking Changes');

    $self->zilla->ensure_built_in;

    my $file = $self->zilla->built_in->file('Changes');

    if ( !-e $file ) {
        $self->log_fatal('No Changes file found');
    }
    elsif ( $self->_get_changes($file) ) {
        $self->log('Changes file has content for release');
    }
    else {
        $self->log_fatal(
            'Changes has no content for ' . $self->zilla->version );
    }

    return;
}

sub _get_changes {
    my $self = shift;
    my $file = shift;

    my $changes = CPAN::Changes->load($file);
    my $release = $changes->release( $self->zilla->version )
        or return;
    my $all = $release->changes
        or return;

    return 1 if grep { @{ $all->{$_} // [] } } keys %{$all};
    return 0;
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Checks Changes for content using CPAN::Changes;

__END__

=for Pod::Coverage .*
