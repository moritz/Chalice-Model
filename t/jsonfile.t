use strict;
use warnings;
use Test::More tests => 16;
use lib 'lib';
use Chalice::Model;

my $year = (localtime)[5] + 1900;
my $m = Chalice::Model->new(
    backend     => 'JSONFile',
    config_file => 't/data/json-file/config.json',
);

isa_ok $m,      'Chalice::Model::JSONFile';
is $m->title,   'A Test Blog', 'title';
is $m->tagline, 'Something witty', 'tagline';

unlink glob "t/data/json-file/posts/$year/*";
ok !$m->post_by_url("$year/foo-bar"), 'post not there yet';
my @posts = $m->newest_posts(5);
is scalar(@posts), 0, 'No posts yet';

ok !eval { $m->create_post() }, 'empty create_post fails';
my %data = (
    title       => 'foo bar',
    url         => 'foo/../../bar',
    body        => 'some test',
    body_format => 'rawhtml',
);
ok !eval { $m->create_post(%data) }, 'disallow ".." in URLs';
delete $data{url};
my $post;
ok eval {$post = $m->create_post(%data); 1 }, 'can create a post with autogenerated URL';
is $post->title, 'foo bar', 'title preserved';
is +(split qr{/}, $post->url)[1], 'foo-bar', 'autogenerated URL works out';

ok +($post = $m->post_by_url("$year/foo-bar")), 'can retrieve post by URL';
is $post->title, 'foo bar', '... and it has the right title';
is $post->body_rendered, 'some test', 'rawhtml just copies verbatime';
$post->delete;
ok !defined($m->post_by_url("$year/foo-bar")), 'after ->delete, the post is gone';


$m->create_post(title => 1, body => 11, body_format => 'rawhtml');
$m->create_post(title => 2, body => 12, body_format => 'rawhtml');
$m->create_post(title => 3, body => 13, body_format => 'rawhtml');

@posts = $m->newest_posts();
is scalar(@posts), 3, 'Four posts';
is join(', ', map $_->title, @posts), '3, 2, 1',
    'got posts in order';

