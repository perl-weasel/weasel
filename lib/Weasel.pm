
=head1 NAME

Weasel - Perl's php/Mink-inspired abstracted web-driver framework

=head1 VERSION

0.03

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

While heavily inspired by Mink, C<Weasel> aims to improve over it
by being extensible, providing not just access to the underlying
browser, yet to provide building blocks for further development
and abstraction.

L<Pherkin::Extension::Weasel> provides integration with
L<Test::BDD::Cucumber> (aka pherkin), for BDD testing.

For the actual page interaction, this module needs a driver to
be installed.  Currently, that means L<Weasel::Driver::Selenium2>.
Other driver implementations, such as L<Sahi|http://sahipro.com/>
can be independently developed and uploaded to CPAN, or contributed.
(We welcome and encourage both!)


=head2 DIFFERENCES WITH OTHER FRAMEWORKS

=over

=item Mnemonics for element lookup patterns

The central registry of xpath expressions to find common page elements
helps to keep page access code clean. E.g. compare:

   use Weasel::FindExpanders::HTML;
   $session->page->find('*contains', text => 'Some text');

With

   $session->page->find(".//*[contains(.,'Some text')]
                              [not(.//*[contains(.,'Some text')])]");

Multiple patterns can be registered for a single mnemonic, which
will be concatenated to a single xpath expression to find the matching
tags in a single driver query.

Besides good performance, this has the benefit that the following

   $session->page->find('*button', text => 'Click!');

can be easily extended to match
L<Dojo toolkit's|http://dojotoolkit.org/documentation/> buttons, which
on the HTML level don't contain visible button or input tags, simply
by using the widget support set:

   use Weasel::Widgets::Dojo;

=item Widgets encapsulate specific behaviours

All elements in C<Weasel> are of the base type C<Weasel::Element>, which
encapsulates the regular element interactions (click, find children, etc).

While most elements will be represented by C<Weasel::Element>, it's possible
to implement other wrappers.  These offer a logical extension point to
implement tag-specific utility functions.  E.g.
C<Weasel::Widgets::HTML::Select>, which adds the utility function
C<select_option>.

These widgets also offer a good way to override default behaviours.  One
such case is the Dojo implementation of a 'select' element.  This element
replaces the select tag entirely and in contrast with the original, doesn't
keep the options as child elements of the 'select'-replacing tag.  By using
the Dojo widget library

   use Weasel::Widget::Dojo;

the lack of the parent/child relation between the the select and its options
is transparently handled by overriding the widget's C<find> and C<find_all>
methods.

=back

=cut


package Weasel;

use strict;
use warnings;

use Moose;

our $VERSION = '0.03';

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
