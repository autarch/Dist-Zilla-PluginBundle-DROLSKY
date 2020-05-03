package Dist::Zilla::Plugin::DROLSKY::RunExtraTests;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '1.09';

use File::Which qw( which );

use Moose;

extends 'Dist::Zilla::Plugin::RunExtraTests';

with 'Dist::Zilla::Plugin::DROLSKY::Role::CoreCounter';

# Dist::Zilla provides no way to pass a `-j` option when running dzil release
# but I really would like faster releases.
sub default_jobs {
    return shift->_core_count;
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Subclasses RunExtraTests to always run tests in parallel

__END__

=for Pod::Coverage .*
