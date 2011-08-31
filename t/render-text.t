use 5.010;
use lib 'lib';
use Chalice::Model::Renderer;
use Test::More tests => 1;

like(Chalice::Model::Renderer->render('text', 'foo&bar'),
   qr{<p>foo&amp;bar</p>}, '& escaped, paragraphs wrapped');
