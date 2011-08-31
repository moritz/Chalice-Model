use 5.010;
use lib 'lib';
use Chalice::Model::Renderer;
use Test::More tests => 1;

like(Chalice::Model::Renderer->render('pod', "=head1 foo\n\nL<http://perl6.org/>"),
   qr{<a href="http://perl6.org/"}, 'pod renders links');
