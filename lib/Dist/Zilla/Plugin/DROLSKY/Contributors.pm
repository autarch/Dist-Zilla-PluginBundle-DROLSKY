package Dist::Zilla::Plugin::DROLSKY::Contributors;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '0.38';

use Moose;

with 'Dist::Zilla::Role::BeforeBuild', 'Dist::Zilla::Role::AfterBuild';

my $weaver_ini = <<'EOF';
[@CorePrep]

[Name]
[Version]

[Region  / prelude]

[Generic / SYNOPSIS]
[Generic / DESCRIPTION]

[Leftovers]

[Region  / postlude]

[Authors]
[Contributors]
[Legal]
EOF

my $mailmap = <<'EOF';
Dave Rolsky <autarch@urth.org> <devnull@localhost>
EOF

my %files = (
    'weaver.ini' => $weaver_ini,
    '.mailmap'   => $mailmap,
);

has _files_written => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] },
);

# These files need to actually exist on disk for the Pod::Weaver plugin to see
# them, so we can't simply add them as InMemory files via file injection.
sub before_build {
    my $self = shift;

    for my $file ( keys %files ) {
        next if -f $file;

        open my $fh, '>:encoding(UTF-8)', $file;
        print {$fh} $files{$file}
            or die "Cannot write to $files{$file}: $!";
        close $fh;

        push @{ $self->_files_written() }, $file;
    }

    return;
}

sub after_build {
    my $self = shift;

    unlink $_ for @{ $self->_files_written() };

    return;
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Creates a weaver.ini and .mailmap to populate Contributors in docs

__END__

=for Pod::Coverage .*
