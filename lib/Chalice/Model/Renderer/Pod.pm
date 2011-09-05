use 5.010;
package Chalice::Model::Renderer::Pod;
use Pod::Simple::HTML; # core module since 5.9.something

sub render_cost { 7 }

sub render {
    my $text = "=pod\n\n" . $_[1];
    my $pod = Pod::Simple::HTML->new;
    $pod->set_source(\$text);
    $pod->output_string(\my $html);
    $pod->do_middle;

    return $html;
}

1;

__END__

=head1 NAME

Chalice::Model::Renderer::Pod -- render blog posts in Pod format

=head1 SYNOPSIS

    use Chalice::Model::Renderer;
    my $rendered = Chalice::Model::Renderer->render(
        'Some B<bold> and I<emphasized> statements',
        format => 'pod',
    );

=head1 DESCRIPTION

This module renders blog posts and comments in Pod format by using
L<Pod::Simple::HTML> (core module since perl 5.9.3).

It automatically adds a minimal Pod header for you, so you can start
your blog posts with a paragraph (no need for a leading C<=head1 ...> or
anything).

=head1 METHODS

See L<Chalice::Model::Renderer>

=cut
