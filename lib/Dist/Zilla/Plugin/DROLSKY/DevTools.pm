package Dist::Zilla::Plugin::DROLSKY::DevTools;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '1.17';

use Path::Tiny qw( path );

use Moose;

with qw(
    Dist::Zilla::Plugin::DROLSKY::Role::MaybeFileWriter
    Dist::Zilla::Role::BeforeBuild
);

sub before_build {
    my $self = shift;

    $self->_maybe_write_file(
        'dev-bin/install-xt-tools.sh',
        $self->_install_xt_tools_sh,
        'is executable',
    );
    $self->_maybe_write_file(
        'git/setup.pl',
        $self->_git_setup_pl,
        'is executable',
    );
    $self->_maybe_write_file(
        'git/hooks/pre-commit.sh',
        $self->_git_hooks_pre_commit_sh,
        'is executable',
    );

    return;
}

my $install_xt_tools_sh = <<'EOF';
#!/bin/sh

set -e

TARGET="$HOME/bin"
if [ $(id -u) -eq 0 ]; then
    TARGET="/usr/local/bin"
fi
echo "Installing dev tools to $TARGET"

mkdir -p $TARGET
curl --silent --location \
       https://raw.githubusercontent.com/houseabsolute/ubi/master/bootstrap/bootstrap-ubi.sh |
       sh

"$TARGET/ubi" --project houseabsolute/precious --in "$TARGET"
"$TARGET/ubi" --project houseabsolute/omegasort --in "$TARGET"

echo "Add $TARGET to your PATH in order to use precious for linting and tidying"
EOF

sub _install_xt_tools_sh {$install_xt_tools_sh}

my $git_setup_pl = <<'EOF';
#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw( abs_path );

symlink_hook('pre-commit');

sub symlink_hook {
    my $hook = shift;

    my $dot  = ".git/hooks/$hook";
    my $file = "git/hooks/$hook.sh";
    my $link = "../../$file";

    if ( -e $dot ) {
        if ( -l $dot ) {
            return if readlink $dot eq $link;
        }
        warn "You already have a hook at $dot!\n";
        return;
    }

    symlink $link, $dot
        or die "Could not link $dot => $link: $!";
}
EOF

sub _git_setup_pl {$git_setup_pl}

my $git_hooks_pre_commit_sh = <<'EOF';
#!/bin/bash

status=0

PRECIOUS=$(which precious)
if [[ -z $PRECIOUS ]]; then
    PRECIOUS=./bin/precious
fi

"$PRECIOUS" lint -s
if (( $? != 0 )); then
    status+=1
fi

exit $status
EOF

sub _git_hooks_pre_commit_sh {$git_hooks_pre_commit_sh}

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Creates default perltidyrc and perlcriticrc files if they don't yet exist

__END__

=for Pod::Coverage .*
