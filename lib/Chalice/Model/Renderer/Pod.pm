use 5.010;
package Chalice::Model::Renderer::Pod;
use Pod::Simple::HTML; # core module since 5.9.something

sub render_cost { 7 }

sub render {
    my $text = $_[1];
    my $pod = Pod::Simple::HTML->new;
    $pod->set_source(\$text);
    $pod->output_string(\my $html);
    $pod->do_middle;

    return $html;
}

1;
