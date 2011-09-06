use strict;
use warnings;
use lib 'lib';
use Chalice::Model;
use Chalice::Model::Test qw/test_cm plan_cm/;
use Test::More tests => 2 + plan_cm;


my $m = Chalice::Model->new(
    storage     => 'JSONFile',
    config_file => 't/data/json-file/config.json',
);

isa_ok $m,      'Chalice::Model::JSONFile';
test_cm($m);
ok !eval { $m->create_post(title => 1, body => 1, body_format => 'rawhtml', url => 'foo/..bar') },
    'URL with ".." is forbidden';
