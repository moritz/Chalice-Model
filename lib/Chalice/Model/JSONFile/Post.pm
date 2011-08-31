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

sub title       { $_[0]->{title}        }
sub url         { $_[0]->{url}          }
sub body_source { $_[0]->{body_source}  }

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
}

1;
