package Chalice::Model::JSONFile;
use strict;
use warnings;
use Mojo::JSON;
use File::Basename ();
use Chalice::Model::JSONFile::Post;

my $json = Mojo::JSON->new;

sub new {
    my ($class, %opts) = @_;
    my $config_file = delete $opts{config_file};
    unless (defined $config_file) {
        die "Option 'config_file' is mandatory in the Chalice::Model::JSONFIle backend";
    }
    my $conf = do {
        open my $fh, '<', $config_file
            or die "Cannot open config file '$config_file' for reading: $!";
        my $contents = do { local $/; <$fh> };
        close $fh or die "Error while closing config file '$config_file': $!";
        $json->decode($contents);
    };
    my $self = bless {config_filename => $config_file}, $class;
    for (qw/title tagline/) {
        $self->{$_} = $conf->{$_};
    }
    $self->{data_path} = $conf->{data_path}
                         || File::Basename::dirname($self->{config_filename});

    return $self;
}

sub title       { shift->{title}     }
sub tagline     { shift->{tagline}   }
sub data_path   { shift->{data_path} }

sub update  {
    my $self = shift;
    my $filename = $self->{config_filename};
    die "Updating of blog data not yet implemented in JSONFile -- please edit file '$filename' instead";
}

sub create_post {
    my ($self, %opts) = @_;
    for (qw/body title body_format/) {
        die "$_ is missing in Chalice::Model::JSONFIle->create_post"
            unless exists $opts{$_};
    }
    my $url = $opts{url} || $self->url_from_title($opts{title});
    $self->validate_url($url);
    my %post_data = (
        title           => $opts{title},
        body_source     => $opts{body},
        body_format     => $opts{body_format},
        created         => scalar(localtime),
        last_modified   => scalar(localtime),
        url             => $url,
        filename        => $self->url_to_filename($url),
    );
    $post_data{author} = $opts{author} if exists $opts{author};
    my $post = Chalice::Model::JSONFile::Post->new(
        %post_data
    );
    $post->write;

    return $post;
}

sub validate_url {
    my ($self, $url) = @_;
    die "URLs containg '..' are forebidden"
        if $url =~ /\.\./;
    die "Absolute URLs are forebidden"
        if $url =~ q{^/};
    die "Invalid characters in URL (allowed are a-z, A-Z, _, -, /)"
        if $url !~ q{^[a-zA-Z0-9_/-]+$};
}

sub url_from_title {
    my ($self, $title) = @_;
    $title =~ s{[^a-zA-Z0-9_/-]+}{-}g;
    $title =~ s/-{2,}/-/g;
    $title = substr($title, 0, 25);
    my $year = (localtime)[5] + 1900;
    return "$year/$title";
}

sub url_to_filename {
    my ($self, $url) = @_;
    return $self->data_path . '/posts/' . $url . '.json';
}

1;
