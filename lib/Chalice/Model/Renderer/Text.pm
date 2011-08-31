use 5.010;
package Chalice::Model::Renderer::Text;

sub render_cost { 1 }
sub render {
    my $text = $_[1];
    my @paragraphs = split /\n\s*\n/, $text;
    my %html_escapes = (
        '&' => '&amp;',
        '<' => '&lt;',
        '>' => '&gt;',
        '"' => '&quot;',
    );
    for (@paragraphs) {
        s/([&<>"])/$html_escapes{$1}/g;
    }
    return join "\n", map "<p>$_</p>\n", @paragraphs;
}

1;
