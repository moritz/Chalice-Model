package Chalice::Model::JSONFile::Post;
use Mojo::JSON;
use File::Basename ();
use File::Path ();
use parent qw/Chalice::Model::Post/;
use strict;
use warnings;

# this seems liek overkill, but it does make testing easier of 
# retrieval of posts ordered by timestamp -- otherwise we'd have to
# sleep(1) between creation of posts.
use Time::HiRes qw/time/;

use Scalar::Util qw/weaken/;

sub new {
    my ($class, %opts) = @_;
    weaken $opts{model};
    my $self = bless \%opts, $class;
    $self->_timestamp;
    $self;
}

sub new_from_file {
    my ($class, $filename, $model) = @_;
    open my $fh, '<', $filename
        or die "Cannot open '$filename' for reading a blog post from it: $!";
    my $data = Mojo::JSON->new->decode(do { local $/; <$fh> });
    $data->{filename} = $filename;
    $data->{model}    = $model;
    weaken $data->{model};
    my $self = bless $data, $class;
    $self->_timestamp;
    $self
}

sub _timestamp {
    my $self = shift;
    my $ts = time;
    $self->{creation_date}     //= $ts;
    $self->{modification_date} //= $ts;
    $self;
}

sub write {
    my $self = shift;
    my %self_copy = %$self;
    my $filename = delete $self_copy{filename};
    delete $self_copy{model};
    my $dir = File::Basename::dirname($filename);
    unless (-d $dir) {
        File::Path::mkpath($dir);
    }
    open my $fh, '>', $filename
        or die "Cannot open '$filename' for storing a blog post in it: $!";
    print { $fh } Mojo::JSON->new->encode(\%self_copy)
        or die "Cannot write post data to '$filename': $!";
    print  { $fh } "\n";
    close $fh
        or die "Error while closing file '$filename' after writing post: $!";
    $self->model->write_index_file;
    $self;
}

sub update {
    my ($self, %opts) = @_;
    $opts{modification_date} //= time;
    delete $opts{$_} for qw/model filename/;
    for (keys %opts) {
        $self->{$_} = $opts{$_};
    }
    $self->write;
    # just to be on the safe side
    $self->model->write_index_file;
    $self;
}

sub delete {
    my $self = shift;
    my $filename = $self->{filename};
    unlink $filename or die "Cannot delete '$filename': $!";
    $self->model->write_index_file;
    $self;
}

sub body_rendered {
    my $self = shift;
    require Chalice::Model::Renderer;
    # TODO: add caching here
    Chalice::Model::Renderer->render($self->body_source, format => $self->body_format);
}

1;
