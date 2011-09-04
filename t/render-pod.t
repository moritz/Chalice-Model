use 5.010;
use lib 'lib';
use Chalice::Model::Renderer;
use Test::More tests => 1;

like(Chalice::Model::Renderer->render("L<http://perl6.org/>", format => 'pod'),
   qr{<a href="http://perl6.org/"}, 'pod renders links');
