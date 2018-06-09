package Dist::Zilla::Plugin::DROLSKY::Contributors;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '0.98';

use Moose;

with 'Dist::Zilla::Role::BeforeBuild';

my $mailmap = <<'EOF';
Dave Rolsky <autarch@urth.org> <devnull@localhost>
EOF

my %files = (
    '.mailmap' => $mailmap,
);

# These files need to actually exist on disk for the Pod::Weaver plugin to see
# them, so we can't simply add them as InMemory files via file injection.
sub before_build {
    my $self = shift;

    for my $file ( keys %files ) {
        next if -e $file;

        open my $fh, '>:encoding(UTF-8)', $file;
        print {$fh} $files{$file}
            or die "Cannot write to $files{$file}: $!";
        close $fh;
    }

    return;
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Creates a .mailmap to populate Contributors in docs

__END__

=for Pod::Coverage .*
