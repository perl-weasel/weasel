
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

use Try::Tiny;
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

=cut

has 'page' => (is => 'ro',
               isa => 'Weasel::Element::Document',
               builder => '_page_builder');

sub _page_builder {
    my $self = shift;

    return Weasel::Element::Document->new(session => $self);
}


=back

=head1 METHODS


=over

=item find($element, $pattern, $args)

=cut

sub find {
    my ($self, @args) = @_;
    my $rv;

    $self->wait_for( sub {
        my @rv;
        try {
            @rv =  @{$self->find_all(@args)};
        }
        catch {
            ###TODO add logger statement warning of consumed error
        };
        return $rv = shift @rv;

                     });

    return $rv;
}

=item find_all($element, $pattern, $args)

=cut

sub find_all {
    my ($self, $element, $pattern, %args) = @_;

    my $expanded_pattern = expand_finder_pattern($pattern, \%args);
    my @rv =
        map { $self->_wrap_widget($_) }
        $self->driver->find_all($element->_id,
                                $expanded_pattern,
                                $args{scheme});
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

=item screenshot($fh)

=cut

sub screenshot {
    my ($self, $fh) = @_;

    $self->driver->screenshot($fh);
}

=item wait_for($callback)

Waits until $callback->() returns true, or C<wait_timeout> expires
(if the driver supports it) -- whichever comes first.x

=cut

sub wait_for {
    my ($self, $callback) = @_;

    $self->driver->wait_for($callback);
}

=item _wrap_widget($_id)

Finds all matching widget selectors to instantiate an element off of.

In case of multiple matches, selects the most specific match
(most matched criteria).

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
