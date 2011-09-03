package Chalice::Model::SQLite::Post;
use strict;
use warnings;
use parent qw/Chalice::Model::Post/;
use Scalar::Util qw/weaken/;
use Time::HiRes qw/time/;

sub new {
    my ($class, %opts) = @_;
    weaken $opts{model};
    bless \%opts, $class;
}

sub body_rendered { $_[0]->{body_rendered} }

sub delete {
    my $self = shift;
    my $sth = $self->model->dbh->prepare_cached(
        'DELETE FROM chalice_posts WHERE url = ?'
    );
    $sth->execute($self->url);
    $sth->finish;
}

sub update {
    my ($self, %opts) = @_;
    my $dbh = $self->model->dbh;
    $opts{modification_date} //= time;
    my $sql = 'UPDATE chalice_posts SET '
              . join(', ', map { $dbh->quote_identifier($_) . ' =  ?' } keys %opts)
              . ' WHERE url = ?';
    my $sth = $dbh->prepare_cached($sql);
    $sth->execute(values(%opts), $self->url);
    $self->{$_} = $opts{$_} for keys %opts;
    $self;
}

1;
