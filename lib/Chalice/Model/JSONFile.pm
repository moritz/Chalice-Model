package Chalice::Model::JSONFile;
use strict;
use warnings;
use Mojo::JSON;
use File::Basename ();
use Chalice::Model::JSONFile::Post;
use List::Util qw/min/;
use 5.010;

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
                         // File::Basename::dirname($self->{config_filename});

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
    my $url = $opts{url} // $self->url_from_title($opts{title});
    $self->validate_url($url);
    my %post_data = (
        title           => $opts{title},
        body_source     => $opts{body},
        body_format     => $opts{body_format},
        url             => $url,
        filename        => $self->url_to_filename($url),
        model           => $self,
    );
    for (qw/author creation_date modification_date/) {
        $post_data{$_} = $opts{$_} if exists $opts{$_};
    }
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
    die "Invalid characters in URL (allowed are a-z, A-Z, _, -, /, .)"
        if $url !~ q{^[a-zA-Z0-9_/.-]+$};
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

sub post_by_url {
    my ($self, $url) = @_;
    return unless eval { $self->validate_url($url); 1 };
    my $filename = $self->url_to_filename($url);
    return unless -e $filename;
    Chalice::Model::JSONFile::Post->new_from_file($filename, $self);
}

sub newest_posts {
    my ($self, $count) = @_;
    $count //= 10;
    if (open my $fh, '<', $self->_index_filename) {
        my @posts = @{ $json->decode(do { local $/; <$fh> }) };
        close $fh;
        my $max_idx = min $count - 1, $#posts;
        return map $self->post_by_url($_->{url}), @posts[0..$max_idx];
    } else {
        $self->write_index_file;
        my @posts = $self->all_posts;
        my $max_idx = min $count - 1, $#posts;
        return @posts[0..$max_idx];
    }
}

sub posts_by_url_prefix {
    my ($self, $prefix, $limit) = @_;
    $prefix = quotemeta $prefix;
    my $index_fn = $self->_index_filename;
    open my $fh, '<', $index_fn
        or die "Cannot open index file '$index_fn' for reading: $!";
    my @all_posts = @{ $json->decode(do { local $/; <$fh> }) };
    my @posts;
    for (@all_posts) {
        next unless $_->{url} =~ /^$prefix/;
        push @posts, $self->post_by_url($_->{url});
        last if defined $limit && @posts >= $limit;
    }
    return @posts;
}

sub all_posts {
    my $self       = shift;
    my $p          = $self->data_path;
    my @post_files = grep -e, glob "$p/posts/*/*.json";
    my @posts      = map  Chalice::Model::JSONFile::Post->new_from_file($_, $self),
                          @post_files;
    return sort { $b->creation_date <=> $a->creation_date }
                @posts;
}

sub _index_filename {
    shift->data_path . '/index.json';
}

sub write_index_file {
    my $self = shift;
    my @posts = $self->all_posts;
    @posts = map { { url => $_->url, timestamp => $_->creation_date } } @posts;
    use autodie;
    open my $h, '>', $self->_index_filename;
    print { $h } $json->encode(\@posts);
    $self;
}

1;
__END__

=head1 NAME

Chalice::Model::JSONFile - a JSON file storage backend for Chalice::Model

=head1 SYNOPSIS

Create a directory for the blog files, and put a file C<config.json> into it
which looks like this:
    
    {
        "title":    "Your Blog Title",
        "tagline":  "a second line describing the blog a bit more"
    }

And then access Chalice::Model::JSONFile as

    use Chalice::Model;
    my $config_file = "path/to/newly/made/config.json";
    my $model = Chalice::Model->new(
        backend     => 'JSONFile',
        config_file => $config_file,
    );

The methods are documented in L<Chalice::Model>.

=head1 DESCRIPTION

This backend stores blog posts and configuration in JSON files. It expects
URLs to be of the form C<directory/post-without-any-further-slashes>, and
supplies the current year as default directory if the URL is not supplied
(but rather generated from the title).

If the config file is stored in C<$path/config.json>, a post of URL
C<foo/bar> is stored in C<$path/posts/foo/bar.json>. An index file is
generated in C<$path/index.json>.

=cut
