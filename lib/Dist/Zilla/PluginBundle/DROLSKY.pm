package Dist::Zilla::PluginBundle::DROLSKY;

use strict;
use warnings;

use Dist::Zilla;

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

has stopwords => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has next_release_width => (
    is      => 'ro',
    isa     => 'Int',
    default => 8,
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

sub _plugin_options_for {
    $_[0]->__plugin_options_for( $_[1] ) // {};
}

sub _build_plugins {
    my $self = shift;

    return [
        $self->make_tool(),

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
            CheckPrereqsIndexed
            InstallGuide
            MetaJSON
            MetaResources
            NextRelease
            PkgVersion
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

    if ( $args{stopwords} && !ref $args{stopwords} ) {
        $args{stopwords} = [ delete $args{stopwords} ];
    }
    $args{stopwords} //= [];

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
            @{ $self->_plugins }, );

    return;
}

sub _build_plugin_options {
    my $self = shift;

    return {
        Authority => { authority => 'cpan:' . $self->authority() },
        MetaResources => $self->_meta_resources(),
        NextRelease   => {
            format => '%-' . $self->next_release_width() . 'v %{yyyy-MM-dd}d'
        },
        'Test::PodSpelling' => { stopwords => $self->stopwords() },
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
