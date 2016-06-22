
=head1 NAME

Weasel::Session - Connection to an encapsulated test driver

=head1 VERSION

0.01

=head1 SYNOPSIS

  use Weasel;
  use Weasel::Session;
  use Weasel::Driver::Selenium2;

  my $weasel = Weasel->new(
       default_session => 'default',
       sessions => {
          default => Weasel::Session->new(
            driver => Weasel::Driver::Selenium2->new(%opts),
          ),
       });

  $weasel->session->get('http://localhost/index');


=head1 DESCRIPTION



=cut

package Weasel::Session;


use strict;
use warnings;

use Moose;

use Weasel::Element::Document;
use Weasel::FindExpanders qw/ expand_finder_pattern /;
use Weasel::WidgetHandlers qw| best_match_handler_class |;

=head1 ATTRIBUTES

=over

=item driver

Holds a reference to the sessions's driver.

=cut

has 'driver' => (is => 'ro',
                 required => 1,
                 handles => {
                     'start' => 'start',
                     'stop' => 'stop',
                     'restart' => 'restart',
                     'started' => 'started',
                 });

=item widget_groups

Contains the list of widget groups to be

=cut

has 'widget_groups' => (is => 'rw');

=item base_url

Holds the prefix that will be prepended to every URL passed
to this API.

=cut

has 'base_url' => (is => 'rw',
                   isa => 'Str',
                   default => '' );

=item page

Returns the root element of the target HTML page (the 'html' tag).

=cut

has 'page' => (is => 'ro',
               isa => 'Weasel::Element::Document',
               builder => '_page_builder');

sub _page_builder {
    my $self = shift;

    return Weasel::Element::Document->new(session => $self);
}


=item retry_timeout

The number of seconds to poll for a condition to become true. Global
setting for the C<wait_for> function.

=cut

has 'retry_timeout' => (is => 'rw',
                        default => 15,
                        isa => 'Num',
    );

=item poll_delay

The number of seconds to wait between state polling attempts. Global
setting for the C<wait_for> function.

=cut

has 'poll_delay' => (is => 'rw',
                     default => 0.5,
                     isa => 'Num',
    );

=back

=head1 METHODS


=over

=item clear($element)

Clears any input entered into elements supporting it.  Generally applies to
textarea elements and input elements of type text and password.

=cut

sub clear {
    my ($self, $element) = @_;

    $self->driver->clear($element->_id);
}

=item click([$element])

Simulates a single mouse click. If an element argument is provided, that
element is clicked.  Otherwise, the browser window is clicked at the
current mouse location.

=cut

sub click {
    my ($self, $element) = @_;

    $self->driver->click(($element) ? $element->_id : undef);
}

=item find($element, $locator [, scheme => $scheme] [, %locator_args])

Finds the first child of C<$element> matching C<$locator>.

See L<Weasel::Element>'s C<find> function for more documentation.

=cut

sub find {
    my ($self, @args) = @_;
    my $rv;

    $self->wait_for(
        sub {
            my @rv = @{$self->find_all(@args)};
            return $rv = shift @rv;
        });

    return $rv;
}

=item find_all($element, $locator, [, scheme => $scheme] [, %locator_args ])

Finds all child elements of C<$element> matching C<$locator>. Returns,
depending on scalar or list context, an arrayref or a list with matching
elements.

See L<Weasel::Element>'s C<find_all> function for more documentation.

=cut

sub find_all {
    my ($self, $element, $pattern, %args) = @_;

    my $expanded_pattern = expand_finder_pattern($pattern, \%args);
    my @rv =
        map { $self->_wrap_widget($_) }
        $self->driver->find_all($element->_id,
                                $expanded_pattern,
                                $args{scheme});
    print STDERR "found " . scalar(@rv) . " elements for $pattern " . (join(', ', %args)) . "\n";
    print STDERR ' - ' . ref($_) . " (" . $_->tag_name . ")\n" for (@rv);
    return wantarray ? @rv : \@rv;
}


=item get($url)

Loads C<$url> into the active browser window of the driver connection,
after prefixing with C<base_url>.

=cut

sub get {
    my ($self, $url) = @_;

    $url = $self->base_url . $url;
    ###TODO add logging warning of urls without protocol part
    # which might indicate empty 'base_url' where one is assumed to be set
    $self->driver->get($url);
}

=item get_attribute($element, $attribute)

Returns the value of the attribute named by C<$attribute> of the element
identified by C<$element>, or C<undef> if the attribute isn't defined.

=cut

sub get_attribute {
    my ($self, $element, $attribute) = @_;

    return $self->driver->get_attribute($element->_id, $attribute);
}

=item get_text($element)

Returns the 'innerHTML' of the element identified by C<$element>.

=cut

sub get_text {
    my ($self, $element) = @_;

    return $self->driver->get_text($element->_id);
}

=item is_displayed($element)

Returns a boolean value indicating if the element identified by
C<$element> is visible on the page, i.e. that it can be scrolled into
the viewport for interaction.

=cut

sub is_displayed {
    my ($self, $element) = @_;

    return $self->driver->is_displayed($element->_id);
}

=item screenshot($fh)

Writes a screenshot of the browser's window to the filehandle C<$fh>.

Note: this version assumes pictures of type PNG will be written;
  later versions may provide a means to query the exact image type of
  screenshots being generated.

=cut

sub screenshot {
    my ($self, $fh) = @_;

    $self->driver->screenshot($fh);
}

=item send_keys($element, @keys)

Send the characters specified in the strings in C<@keys> to C<$element>,
simulating keyboard input.

=cut

sub send_keys {
    my ($self, $element, @keys) = @_;

    $self->driver->send_keys($element->_id, @keys);
}

=item tag_name($element)

Returns the tag name of the element identified by C<$element>.

=cut

sub tag_name {
    my ($self, $element) = @_;

    return $self->driver->tag_name($element->_id);
}

=item wait_for($callback, [ retry_timeout => $number,] [poll_delay => $number])

Polls $callback->() until it returns true, or C<wait_timeout> expires
-- whichever comes first.

The arguments retry_timeout and poll_delay can be used to override the
session-global settings.

=cut

sub wait_for {
    my ($self, $callback, %args) = @_;

    $self->driver->wait_for($callback,
                            retry_timeout => $self->retry_timeout,
                            poll_delay => $self->poll_delay,
                            %args);
}

=item _wrap_widget($_id)

Finds all matching widget selectors to wrap the driver element in.

In case of multiple matches, selects the most specific match
(the one with the highest number of requirements).

=cut

sub _wrap_widget {
    my ($self, $_id) = @_;
    my $best_class = best_match_handler_class(
        $self->driver, $_id, $self->widget_groups) // 'Weasel::Element';
    return $best_class->new(_id => $_id, session => $self);
}

=back

=head1 SEE ALSO

L<Weasel>

=head1 COPYRIGHT

 (C) 2016  Erik Huelsmann

Licensed under the same terms as Perl.

=cut


1;
