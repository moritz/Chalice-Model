use strict;
use warnings;
use lib 'lib';
use Chalice::Model;
use Chalice::Model::Test qw/test_cm plan_cm/;
use Test::More tests => (plan_cm() + 1);

my $dbname = 't/data/sqlite/blog.sqlite';
unlink $dbname;

my $m = Chalice::Model->new(
    storage     => 'SQLite',
    dbname      =>  $dbname,
);
$m->update(title => 'A Test Blog', tagline => 'Something witty');

isa_ok $m,      'Chalice::Model::SQLite';
test_cm $m;
