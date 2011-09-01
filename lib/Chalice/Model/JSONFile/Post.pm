package Chalice::Model::JSONFile::Post;
use Mojo::JSON;
use File::Basename ();
use File::Path ();
use strict;
use warnings;

sub new {
    my ($class, %opts) = @_;
    bless \%opts, $class;
}

sub new_from_file {
    my ($class, $filename) = @_;
    open my $fh, '<', $filename
        or die "Cannot open '$filename' for reading a blog post from it: $!";
    my $data = Mojo::JSON->new->decode(do { local $/; <$fh> });
    $data->{filename} = $filename;
    bless $data, $class;
}

sub title       { $_[0]->{title}        }
sub url         { $_[0]->{url}          }
sub body_source { $_[0]->{body_source}  }
sub body_format { $_[0]->{body_format}  }

sub write {
    my $self = shift;
    my %self_copy = %$self;
    my $filename = delete $self_copy{filename};
    my $dir = File::Basename::dirname($filename);
    unless (-d $dir) {
        File::Path::mkpath($dir);
    }
    open my $fh, '>', $filename
        or die "Cannot open '$filename' for storing a blog post in it: $!";
    printf { $fh } Mojo::JSON->new->encode(\%self_copy)
        or die "Cannot write post data to '$filename': $!";
    print  { $fh } "\n";
    close $fh
        or die "Error while closing file '$filename' after writing post: $!";
    $self;
}

sub delete {
    my $self = shift;
    my $filename = $self->{filename};
    unlink $filename or die "Cannot delete '$filename': $!";
    $self;
}

sub body_rendered {
    my $self = shift;
    require Chalice::Model::Renderer;
    # TODO: add caching here
    Chalice::Model::Renderer->render($self->body_format, $self->body_source);
}

sub creation_date { $_[0]->{creation_date} };

1;
