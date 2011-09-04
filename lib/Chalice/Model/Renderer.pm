package Chalice::Model::Renderer;
use strict;
use warnings;
use Exporter qw/import/;

our @EXPORT_OK = qw/render render_cost/;

sub render_cost {
    my ($class, %opts) = @_;
    my $ns = _namespace(delete $opts{format});
    $ns->render_cost(%opts);
}
sub render {
    my ($class, $text, %opts) = @_;
    my $ns = _namespace(delete $opts{format});
    $ns->render($text, %opts);
}

sub _namespace {
    my $n = ucfirst shift;
    my $namespace = "Chalice::Model::Renderer::$n";
    eval "use $namespace; 1"
        or die "Cannot load $namespace for rendering: $@";
    $namespace;
}
1;
__END__

=head1 NAME

Chalice::Model::Renderer -- interface for rendering blog posts and comments

=head1 SYNOPSIS

    use Chalice::Model::Renderer;
    use utf8;
    my $rendered = Chalice::Model::Renderer->render(
        q[That's a B<bold> statement],
        format => 'pod',
    );

=head1 DESCRIPTION

This is an interface for rendering blog posts and comments from various source
formats. It tries to load C<Chalice::Model::Renderer::$format> (with first
character of C<$format> converted to upper case) and call the C<< ->render >>
class method from that module.

=cut
