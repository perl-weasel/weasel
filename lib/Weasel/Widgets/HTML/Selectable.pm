
=head1 NAME

Weasel::Widgets::HTML::Selectable - Wrapper for selectable elements

=head1 VERSION

0.01

=head1 SYNOPSIS

  my $selectable = $session->page->find('./option');
  $selectable->selected(1);   # select option

=head1 DESCRIPTION


=cut

package Weasel::Widgets::HTML::Selectable;


use strict;
use warnings;

use Moose;
use Weasel::Widgets::HTML::Input;
use Weasel::WidgetHandlers qw/ register_widget_handler /;

extends 'Weasel::Widgets::HTML::Input';

register_widget_handler(
    __PACKAGE__, 'HTML',
    tag_name => 'input',
    attributes => {
        type => $_,
    })
    for (qw/ radio checkbox /);

register_widget_handler(
    __PACKAGE__, 'HTML',
    tag_name => 'option',
    );

=head1 METHODS

=over

=item selected([$value])

Returns selected status of the element. If C<$value> is provided,
sets the selected status.

=cut

sub selected {
    my ($self, $value) = @_;

    $self->session->set_selected($self, $value)
        if defined $value;

    return $self->session->get_selected($self);
}



1;
