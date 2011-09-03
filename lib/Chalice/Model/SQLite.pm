package Chalice::Model::SQLite;
use Chalice::Model::SQLite::Post;
use Chalice::Model::Renderer;
use strict;
use warnings;
use 5.010;
use DBI;
use parent qw/Chalice::Model/;
use Time::HiRes qw/time/;

sub new {
    my ($class, %opts) = @_;
    die "Option 'dbname' is mandatory" unless exists $opts{dbname};
    my $dbname = $opts{dbname};
    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbname", '', '',
            {
                RaiseError                  => 1,
                PrintError                  => 0,
                AutoCommit                  => 1,
                sqlite_see_if_its_a_number  => 1,
            }
        );
    my $self = bless { dbname => $dbname, dbh => $dbh }, $class;
    $self->_deploy_schema_if_necessary;
    return $self;
}

sub _deploy_schema_if_necessary {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $success = eval {
        $dbh->prepare('SELECT * FROM chalice_blog_meta LIMIT 1');
        $dbh->execute;
        1;
    };
    return if $success;
    my $data_pos = tell(DATA);
    local $/ = '';
    local $dbh->{AutoCommit} = 0;
    eval {
        while (<DATA>) {
            $dbh->do($_);
        }
        $dbh->commit;
        seek DATA, $data_pos, 0;
    };
    warn $@ if $@;
}

sub update {
    my ($self, %opts) = @_;
    my $sth = $self->{dbh}->prepare_cached(
        'INSERT OR REPLACE INTO chalice_blog_meta (key, value) VALUES(?, ?)'
    );
    for (keys %opts) {
        $sth->execute($_, $opts{$_});
    }
    $sth->finish;
    $self;
}

sub _get_meta {
    my $self = shift;
    my $sth = $self->{dbh}->prepare_cached(
        'SELECT value FROM chalice_blog_meta WHERE key = ?'
    );
    my @res;
    for (@_) {
        $sth->execute($_);
        my ($val) = $sth->fetchrow_array;
        push @res, $val;
    }
    $sth->finish;
    return @res == 1 ? $res[0] : @res;
}

sub title   { $_[0]->_get_meta('title'  ) }
sub tagline { $_[0]->_get_meta('tagline') }

sub delete_all {
    $_[0]->{dbh}->do('DELETE FROM chalice_posts');
    $_[0];
}

sub post_by_url {
    my ($self, $url) = @_;
    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare_cached('SELECT * FROM chalice_posts WHERE url = ?');
    $sth->execute($url);
    $self->_posts_from_sth($sth);
}

sub _posts_from_sth {
    my ($self, $sth) = @_;
    my @posts;
    while (my $h = $sth->fetchrow_hashref) {
        push @posts, Chalice::Model::SQLite::Post->new(%$h, model => $self);
    }
    $sth->finish;
    return unless @posts;
    @posts == 1 ? $posts[0] : @posts;
}

sub newest_posts {
    my ($self, $limit) = @_;
    $limit //= 10;
    my $sth = $self->{dbh}->prepare_cached(
        'SELECT * FROM chalice_posts ORDER BY creation_date DESC LIMIT ?'
    );
    $sth->execute($limit);
    my @posts;
    while (my $h = $sth->fetchrow_hashref) {
        push @posts, Chalice::Model::SQLite::Post->new(model => $self, %$h);
    }
    @posts;
}

sub create_post {
    my ($self, %opts) = @_;
    for (qw/body title body_format/) {
        die "Option '$_' is missing" unless exists $opts{$_};
    }
    $opts{url} //= $self->url_from_title($opts{title});
    my $ts = time;
    $opts{creation_date}     //= $ts;
    $opts{modification_date} //= $ts;
    $opts{body_source} = delete $opts{body};
    $opts{body_rendered} //= Chalice::Model::Renderer->render(
        $opts{body_format},
        $opts{body_source},
    );
    my @cols = qw/
        url title body_format body_source body_rendered
        author creation_date modification_date
    /;
    my $sql = 'INSERT INTO chalice_posts ('
              . join(', ', @cols)
              . ') VALUES ('
              . join(', ', ('?') x @cols)
              . ')';
    my $sth = $self->{dbh}->prepare_cached($sql);
    $sth->execute(@opts{@cols});
    Chalice::Model::SQLite::Post->new(model => $self, %opts);
}

sub dbh { $_[0]->{dbh} }

# not great, but works for now
sub all_posts { $_[0]->newest_posts(10_000_000) }

sub posts_by_url_prefix {
    my ($self, $prefix, $limit) = @_;
    $prefix =~ s/([|_%])/|$1/g;
    my @params = ("$prefix%");
    my $sql = q[SELECT * FROM chalice_posts WHERE url LIKE ? ESCAPE '|'
                ORDER BY creation_date DESC];

    if (defined $limit) {
        $sql .= ' LIMIT ?';
        push @params, $limit;
    }
    my $sth = $self->{dbh}->prepare_cached($sql);
    $sth->execute(@params);
    $self->_posts_from_sth($sth);
}

1;

__DATA__
CREATE TABLE chalice_blog_meta (
    key STRING PRIMARY KEY,
    value STRING
);

CREATE TABLE chalice_posts (
    url             STRING PRIMARY KEY,
    title           STRING,
    body_format     STRING,
    body_source     STRING,
    body_rendered   STRING,
    author          STRING,
    creation_date   FLOAT,
    modification_date FLOAT
);
