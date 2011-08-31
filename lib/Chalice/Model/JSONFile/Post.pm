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

sub title { $_[0]->{title} }
sub url   { $_[0]->{url}   }

sub write {
    my $self = shift;
    my %self_copy = %$self;
    my $filename = delete $self_copy{filename};
    my $dir = File::Basename::dirname($filename);
    unless (-d $dir) {
        File::Path::mkpath($dir);
    }
    open my $fh, '>', $filename
        or die "Cannot open '$filename' to for writing a post to it: $!";
    printf { $fh } Mojo::JSON->new->encode(\%self_copy)
        or die "Cannot write post data to '$filename': $!";
    print  { $fh } "\n";
    close $fh
        or die "Error while closing file '$filename' after writing post: $!";
    $self;
}

1;
