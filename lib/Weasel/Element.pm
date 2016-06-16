
=head1 NAME

Weasel::Element - The base HTML/Widget element class

=head1 VERSION

0.01

=head1 SYNOPSIS

   my $element = $session->page->find("./input[\@name='phone']");
   my $value = $element->send_keys('555-885-321');

=head1 DESCRIPTION

=cut

package Weasel::Element;

use strict;
use warnings;

use Moose;

=head1 ATTRIBUTES

=over

=item session

=cut

has session => (is => 'ro',
                isa => 'Weasel::Session',
                required => 1);

=item _id

=cut

has _id => (is => 'ro',
            required => 1);

=back

=head1 METHODS

=over

=item find($locator [, $scheme])


=cut

sub find {
    my ($self, @args) = @_;

    return $self->session->find($self, @args);
}

=item find_all($locator [, $scheme])

=cut

sub find_all {
    my ($self, @args) = @_;

    # expand $locator based on framework plugins (e.g. Dojo)
    return $self->session->find_all($self, @args);
}

=item click()

=cut

sub click {
    my ($self) = @_;
    $self->session->click($self);
}

=item send_keys(@keys)

=cut

sub send_keys {
    my ($self, @keys) = @_;

    $self->session->send_keys($self, @keys);
}

=back

=cut


1;
