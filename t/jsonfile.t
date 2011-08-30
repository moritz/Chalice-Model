use strict;
use warnings;
use Test::More tests => 5;
use lib 'lib';
use Chalice::Model;

my $m = Chalice::Model->new(
    backend     => 'JSONFile',
    config_file => 't/data/json-file/config.json',
);

isa_ok $m,      'Chalice::Model::JSONFile';
is $m->title,   'A Test Blog', 'title';
is $m->tagline, 'Something witty', 'tagline';

ok !eval { $m->create_post() }, 'empty create_post fails';
my %data = (
    title       => 'foo bar',
    url         => 'foo/../../bar',
    body        => 'some test',
    body_format => 'raw_html',
);
ok !eval { $m->create_post(%data) }, 'disallow ".." in URLs';
