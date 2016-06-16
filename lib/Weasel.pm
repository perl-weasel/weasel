
=head1 NAME

Weasel - Perl's php/Mink-inspired abstracted web-driver framework

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

This module abstracts away the differences between the various
web-driver protocols, like the Mink project does for PHP.

=cut


package Weasel;

use strict;
use warnings;

use Moose;

our $VERSION = '0.01';

=head1 ATTRIBUTES


=over

=item default_session

The name of the default session to return from C<session>, in case
no name argument is provided.

=cut

has 'default_session' => (is => 'rw',
                          isa => 'Str',
                          default => 'default');

=item sessions

Holds the sessions registered with the C<Weasel> instance.

=cut

has 'sessions' => (is => 'ro',
                   isa => 'HashRef[Weasel::Session]',
                   default => sub { {} } );

=back

=head1 METHODS

=over

=item session([$name [, $value]])

Returns the session identified by C<$name>.

If C<$value> is specified, it's associated with the given C<$name>.

=cut

sub session {
    my ($self, $name, $value) = @_;

    $name //= $self->default_session;
    $self->sessions->{$name} = $value
        if defined $value;

    return $self->sessions->{$name};
}


=back

=head1 CONTRIBUTORS

Erik Huelsmann

=head1 MAINTAINERS

Erik Huelsmann

=head1 BUGS

Bugs can be filed in the GitHub issue tracker for the Weasel project:
 https://github.com/perl-weasel/weasel/issues

=head1 SOURCE

The source code repository for Weasel is at
 https://github.com/perl-weasel/weasel

=head1 SUPPORT

Community support is available through
L<perl-weasel@googlegroups.com|mailto:perl-weasel@googlegroups.com>.

=head1 COPYRIGHT

 (C) 2016  Erik Huelsmann

Licensed under the same terms as Perl.

=cut


1;
