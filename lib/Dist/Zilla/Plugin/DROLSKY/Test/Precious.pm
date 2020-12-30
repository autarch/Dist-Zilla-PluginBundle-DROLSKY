package Dist::Zilla::Plugin::DROLSKY::Test::Precious;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '1.12';

use Dist::Zilla::File::InMemory;

use Moose;

with 'Dist::Zilla::Role::FileGatherer';

my $test = <<'EOF';
use strict;
use warnings;

use Test::More;

use Capture::Tiny qw( capture );
use FindBin qw( $Bin );

chdir "$Bin/../.."
    or die "Cannot chdir to $Bin/../..: $!";

my ( $out, $err ) = capture { system(qw( precious lint -a )) };
is( $? >> 8, 0, 'precious exited with 0' );
is( $err, q{}, 'no output to stderr' );

done_testing();
EOF

sub gather_files {
    my $self = shift;

    $self->add_file(
        Dist::Zilla::File::InMemory->new(
            name    => 'xt/author/precious.t',
            content => $test,
        )
    );

    return;
}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Creates a test that runs precious

__END__

=for Pod::Coverage .*
