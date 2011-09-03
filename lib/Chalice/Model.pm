package Chalice::Model;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.01';

sub new {
    my ($class, %opts) = @_;
    my $storage = delete $opts{storage};
    die "The 'storage' option is mandatoray!" unless defined $storage;
    eval "use Chalice::Model::$storage (); 1"
        or die "Cannot load storage '$storage': $@";
    "Chalice::Model::$storage"->new(%opts);
}

sub url_from_title {
    my ($self, $title) = @_;
    $title = lc $title;
    $title =~ s{[^a-zA-Z0-9_/-]+}{-}g;
    $title =~ s/-{2,}/-/g;
    $title = substr($title, 0, 25);
    my $year = (localtime)[5] + 1900;
    return "$year/$title";
}

1;

__END__

=head1 NAME

Chalice::Model - Data model for a blog system

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Chalice::Model;
    use 5.010; # Chalice::Model needs it anyway

    my $model = Chalice::Model->new(
        storage => 'SQL',
        url_prefix => '/blog/',     # prefix for turning relative
                                    # URLs into absolute URLs
        # storage specific options go here
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

    my @ancient_history = $model->posts_by_url_prefix('2009');

=head1 DESCRIPTION

I<Chalice> is inspired by Blosxom, a light weight Perl-based blogging system.
I<Chalice::Model> is a bit less light than Blosxom, and serves as an
abstraction layer over different storage systems.

It provides all the functionality you need for your blog system, like
retrieving posts and lists of posts, creating new ones, listing entries by
date etc.

=head1 METHODS

Method calls are generally of the form
C<$obj->method(opt1 => $val1, opt2 => $val2)>, sometimes also of the form
C<$obj->method($argument, opt1 => $val1, ...)>.

If a "post" is mentioned in the documentation below, it refers to
a C<Chalice::Model::$storage::Post> object, where C<$storage> refers to the
storage class.

=head2 new

Creates a new Chalice::Model object. In truth it loads the storage
specified by the C<storage> option, and creates an instance thereof.

=head2 all_posts

Returns a list of all posts, newest (by creation time) first.

=head2 newest_posts

Argument: C<$limit> (default 10)

Returns a list of up to C<$limit> posts, newest (by creation time) first

=head2 posts_by_url_prefix

Arguments: C<$url_prefix>, C<$limit> (optional)

Returns a list of posts with URLs that begin with C<$url_prefix>, newest
(by creation time) first. If C<$limit> is present, return only up to
C<$limit> posts, otherwise all matching posts.

Storage backends may decide to only implement that lookup URL parts at slash
boundaries, so if the URLs C<ab/cd/e> are stored C<ab/ef/g>, valid values
for prefix would be C<ab>, C<ab/cd> and C<ab/ef>, but not C<a> or C<ab/e>.

This method is useful for retrieving posts by category or year, whatever you
choose to base your URL scheme on.

=head2 create_post

Mandatory options: C<title>, C<body>, C<body_format>

Optional options: C<url>, C<creation_date>, C<modification_date>, C<author>

Creates and returns a new post. C<title> is the title of the post in plain
text, C<body> is the source of the body of the post, as entered by the user.
C<body_format> is the name of the format of the body, see
L<Chalice::Model::Renderer> for details.

If no C<url> is given, the backend will generate one for you. C<author> is not
yet used in any way, simply stored along with the post. See L</URLs> below
for more notes on URLs.

C<creation_date> and C<modification_date> are UNIX
timestamps, and will be set automatically unless supplied. Supplying them only
makes sense for imporint legacy data.

=head2 delete_all

Delete all posts from the storage. (Usually only useful for testing).

=head1 METHODS in ::Post classes

A C<Chalice::Model::$storage::Post> class provides at least the
following methods:

=head2 body_format

Returns the source format of the body. See L<Chalice::Model::Renderer> for
details.

=head2 body_rendered

Returns a HTML string of the rendered body of this post

=head2 body_source

Returns the source of body of the blog post

=head2 creation_date

UNIX timestamp of the creation date

=head2 delete

Delete this post

=head2 modification_date

UNIX timestamp of the last modification date

=head2 title

Returns the title of the post

=head2 update

Options: same as C<create_post>, except that all of them are optional
in C<update>.

Updates the arguments that are passed along, so for example
C<$post->update(title => 'new title')> changes the title.

Note that updating the URL is usally a very bad idea, there are no mechanisms
in place to install redirects, updating internal links to the post etc. 
See also: L<http://www.w3.org/Provider/Style/URI.html>.

=head2 url

Returns the local URL of the post

=head1 URLs

The typical URL of a blog post is something like
C<http://example.com/blog/2011/why-i-like-perl>.

In this example the
C<http://example.com/blog/> part should be passed as the C<url_prefix>
option to C<Chalice::Model->new>. (Just C</blog/> might work too, but would
make links in RSS feeds more fragile).

The C<2011/why-i-like-perl> part is used internally as the url of the
individual blog post, which must never start with a slash, and may be
constrained by the storage. For example file-based storage backends might
disallow two dots in a row in URLs and special characters
(for security reasons).

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

