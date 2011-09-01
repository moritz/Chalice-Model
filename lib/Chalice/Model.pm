package Chalice::Model;

use 5.010;
use strict;
use warnings;

=head1 NAME

Chalice::Model - Data model for a blog system

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use Chalice::Model;
    use 5.010; # Chalice::Model needs it anyway

    my $model = Chalice::Model->new(
        backend => 'SQL',
        url_prefix => '/blog/',     # prefix for turning relative
                                    # URLs into absolute URLs
        # backend specific options go here
    );

    say $model->title, " " x 4, $model->tagline;
    my $post  = $model->post_by_url('2011/fancy-url-here');
    my @list  = $model->newest_posts(10);
    if ($post) {
        say $post->title_rendered;
        say "by ", $post->author, " on ", $post->creation_date;
        say  '';
        say $post->body_rendered;
    }

=head1 DESCRIPTION

I<Chalice> is inspired by Blosxom, a light weight Perl-based blogging system.
I<Chalice::Model> is a bit less light than Blosxom, and serves as an
abstraction layer over different storage systems.

It provides all the functionality you need for your blog system, like
retrieving posts and lists of posts, creating new ones, listing entries by
date etc.

=head1 METHODS

=head2 new

Create a new Chalice::Model object. In truth it loads the backend
specified by the C<backend> option, and creates an instance thereof.

=cut

sub new {
    my ($class, %opts) = @_;
    my $backend = delete $opts{backend};
    die "The 'backend' option is mandatoray!" unless defined $backend;
    eval "use Chalice::Model::$backend (); 1"
        or die "Cannot load backend '$backend': $@";
    "Chalice::Model::$backend"->new(%opts);
}

=head1 AUTHOR

Moritz Lenz, C<< <moritz at faui2k3.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-chalice-model at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Chalice-Model>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Chalice::Model


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Chalice-Model>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Chalice-Model>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Chalice-Model>

=item * Search CPAN

L<http://search.cpan.org/dist/Chalice-Model/>

=back


=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Moritz Lenz.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Chalice::Model
