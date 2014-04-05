package Dist::Zilla::PluginBundle::DROLSKY;

use v5.10;

use strict;
use warnings;

use Dist::Zilla;

# Not used here, but we want it installed
use Pod::Weaver::Section::Contributors;

# For the benefit of AutoPrereqs
use Dist::Zilla::Plugin::Authority;
use Dist::Zilla::Plugin::AutoPrereqs;
use Dist::Zilla::Plugin::ContributorsFromGit;
use Dist::Zilla::Plugin::CopyReadmeFromBuild;
use Dist::Zilla::Plugin::CheckPrereqsIndexed;
use Dist::Zilla::Plugin::InstallGuide;
use Dist::Zilla::Plugin::Meta::Contributors;
use Dist::Zilla::Plugin::MetaJSON;
use Dist::Zilla::Plugin::MetaResources;
use Dist::Zilla::Plugin::NextRelease;
use Dist::Zilla::Plugin::PkgVersion;
use Dist::Zilla::Plugin::PruneFiles;
use Dist::Zilla::Plugin::ReadmeFromPod;
use Dist::Zilla::Plugin::SurgicalPodWeaver;
use Dist::Zilla::Plugin::EOLTests;
use Dist::Zilla::Plugin::NoTabsTests;
use Dist::Zilla::Plugin::PodCoverageTests;
use Dist::Zilla::Plugin::PodSyntaxTests;
use Dist::Zilla::Plugin::Test::CPAN::Changes;
use Dist::Zilla::Plugin::Test::Compile;
use Dist::Zilla::Plugin::Test::Pod::LinkCheck;
use Dist::Zilla::Plugin::Test::Pod::No404s;
use Dist::Zilla::Plugin::Test::PodSpelling;
use Dist::Zilla::Plugin::Test::Synopsis;
use Dist::Zilla::Plugin::Git::Check;
use Dist::Zilla::Plugin::Git::Commit;
use Dist::Zilla::Plugin::Git::Tag;
use Dist::Zilla::Plugin::Git::Push;

use Moose;

with 'Dist::Zilla::Role::PluginBundle::Easy';

has dist => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has make_tool => (
    is      => 'ro',
    isa     => 'Str',
    default => 'MakeMaker',
);

has authority => (
    is      => 'ro',
    isa     => 'Str',
    default => 'DROLSKY',
);

has prune_files => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has prereqs_skip => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
    handles  => {
        _has_prereqs_skip => 'count',
    },
);

has stopwords => (
    traits   => ['Array'],
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
    handles  => {
        _has_stopwords => 'count',
    },
);

has next_release_width => (
    is      => 'ro',
    isa     => 'Int',
    default => 8,
);

has remove => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
);

has _plugins => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_plugins',
);

has _plugin_options => (
    traits   => ['Hash'],
    is       => 'ro',
    isa      => 'HashRef[HashRef]',
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_plugin_options',
    handles  => {
        __plugin_options_for => 'get',
    },
);

=begin Pod::Coverage

  mvp_multivalue_args

=end Pod::Coverage

=cut

sub mvp_multivalue_args {
    return qw( prune_files prereqs_skip remove stopwords );
}

sub _plugin_options_for {
    $_[0]->__plugin_options_for( $_[1] ) // {};
}

sub _build_plugins {
    my $self = shift;

    my %remove = map { $_ => 1 } @{ $self->remove() };
    return [
        grep { !$remove{$_} } $self->make_tool(),

        # from @Basic
        qw(
            GatherDir
            PruneCruft
            ManifestSkip
            MetaYAML
            License
            Readme
            ExtraTests
            ExecDir
            ShareDir

            Manifest

            TestRelease
            ConfirmRelease
            UploadToCPAN
            ),

        qw(
            Authority
            AutoPrereqs
            ContributorsFromGit
            CopyReadmeFromBuild
            CheckPrereqsIndexed
            InstallGuide
            Meta::Contributors
            MetaJSON
            MetaResources
            NextRelease
            PkgVersion
            PruneFiles
            ReadmeFromPod
            SurgicalPodWeaver
            ),

        qw(
            EOLTests
            NoTabsTests
            PodCoverageTests
            PodSyntaxTests
            Test::CPAN::Changes
            Test::Compile
            Test::Pod::LinkCheck
            Test::Pod::No404s
            Test::PodSpelling
            Test::Synopsis
            ),

        # from @Git
        qw(
            Git::Check
            Git::Commit
            Git::Tag
            Git::Push
            ),
    ];
}

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my $p = $class->$orig(@_);

    my %args = ( %{ $p->{payload} }, %{$p} );

    for my $key (qw( prune_files prereqs_skip stopwords )) {
        if ( $args{$key} && !ref $args{$key} ) {
            $args{$key} = [ delete $args{$key} ];
        }
        $args{$key} //= [];
    }

    push @{ $args{stopwords} }, $class->_default_stopwords();

    return \%args;
};

sub _default_stopwords {
    qw(
        DROLSKY
        DROLSKY's
        Rolsky
        Rolsky's
    );
}

sub configure {
    my $self = shift;

    $self->add_plugins(
        [
            'Prereqs' => 'TestMoreDoneTesting' => {
                -phase       => 'test',
                -type        => 'requires',
                'Test::More' => '0.88',
            }
        ]
    );

    $self->add_plugins( map { [ $_ => $self->_plugin_options_for($_) ] }
            @{ $self->_plugins } );

    return;
}

sub _build_plugin_options {
    my $self = shift;

    my @allow_dirty = qw( Changes README );
    return {
        Authority => {
            authority  => 'cpan:' . $self->authority(),
            do_munging => 0,
        },
        AutoPrereqs => {
            (
                $self->_has_prereqs_skip() ? ( skip => $self->prereqs_skip() )
                : ()
            )
        },
        'Git::Check'  => { allow_dirty => \@allow_dirty },
        'Git::Commit' => { allow_dirty => \@allow_dirty },
        MetaResources => $self->_meta_resources(),
        NextRelease   => {
            format => '%-' . $self->next_release_width() . 'v %{yyyy-MM-dd}d'
        },
        PruneFiles => {
            filename => [ qw( README ), @{ $self->prune_files() } ],
        },
        'Test::PodSpelling' => {
            (
                $self->_has_stopwords() ? ( stopwords => $self->stopwords() )
                : ()
            ),
        },
    };
}

sub _meta_resources {
    my $self = shift;

    return {
        'repository.type' => 'git',
        'repository.url' =>
            sprintf( 'git://git.urth.org/%s.git', $self->dist() ),
        'repository.web' =>
            sprintf( 'http://git.urth.org/%s.git', $self->dist() ),
        'bugtracker.web' => sprintf(
            'http://rt.cpan.org/Public/Dist/Display.html?Name=%s',
            $self->dist()
        ),
        'bugtracker.mailto' =>
            sprintf( 'bug-%s@rt.cpan.org', lc $self->dist() ),
        'homepage' =>
            sprintf( 'http://metacpan.org/release/%s', $self->dist() ),
    };
}

1;

# ABSTRACT: DROLSKY's plugin bundle

__END__

=for Pod::Coverage configure
