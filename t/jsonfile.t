use strict;
use warnings;
use Test::More tests => 3;
use lib 'lib';
use Chalice::Model;

my $m = Chalice::Model->new(
    backend     => 'JSONFile',
    config_file => 't/data/json-file/config.json',
);

isa_ok $m,      'Chalice::Model::JSONFile';
is $m->title,   'A Test Blog', 'title';
is $m->tagline, 'Something witty', 'tagline';
