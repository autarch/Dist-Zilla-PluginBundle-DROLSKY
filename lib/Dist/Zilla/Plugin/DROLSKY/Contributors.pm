package Dist::Zilla::Plugin::DROLSKY::Contributors;

use v5.10;

use strict;
use warnings;
use autodie;

use Dist::Zilla::File::InMemory;

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

# These files need to actually exist on disk for the Pod::Weaver plugin to see
# them, so we can't simply add them as InMemory files via file injection.
sub before_build {
    my $self = shift;

    for my $file ( keys %files ) {
        open my $fh, '>:encoding(UTF-8)', $file;
        print {$fh} $files{$file};
        close $fh;
    }

    return;
}

sub after_build {
    my $self = shift;

    unlink $_ for keys %files;

    return;
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Creates a weaver.ini and .mailmap to populate Contributors in docs

__END__

=for Pod::Coverage .*
