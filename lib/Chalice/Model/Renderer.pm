package Chalice::Model::Renderer;
use strict;
use warnings;
use Exporter qw/import/;

our @EXPORT_OK = qw/render render_cost/;

sub render_cost {
    my ($class, $type) = @_;
    my $ns = _namespace($type);
    $ns->render_cost;
}
sub render {
    my ($class, $type, $text) = @_;
    my $ns = _namespace($type);
    $ns->render($text);
}

sub _namespace {
    my $n = ucfirst shift;
    my $namespace = "Chalice::Model::Renderer::$n";
    eval "use $namespace; 1"
        or die "Cannot load $namespace for rendering: $@";
    $namespace;

}
1;
