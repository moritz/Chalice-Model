#!perl

use Test::More tests => 1;

BEGIN {
    use_ok( 'Chalice::Model' ) || print "Bail out!\n";
}

diag( "Testing Chalice::Model $Chalice::Model::VERSION, Perl $], $^X" );
