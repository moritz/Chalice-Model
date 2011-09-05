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

=head1 METHODS

=head2 render

Arguments: C<$text>

Options: C<format> (mandatory), C<url_prefix> (optional)

(class method)

Loads the module of name C<Chlaice::Model::Renderer::ucfirst($format)>
and calls its C<< ->render >> method, passing on the text and all options.

This can be used for rendering blog posts and comments in the format that the
user supplied.

=head2 render_cost

Options: C<format> (mandatory)

(class method)

Returns a guess of how costly rendering in the given format is. The return
value should be between 0 (very cheap, like a verbatim copy) and 10 (very
slow). This method can be used to decide whether the rendered text is
cached.

=cut
