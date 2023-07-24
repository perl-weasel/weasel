
=head1 NAME

Weasel::FindExpanders - Mapping find patterns to xpath locators

=head1 VERSION

0.01

=head1 SYNOPSIS

  use Weasel::FindExpanders qw( register_find_expander );

  register_find_expander(
    'button',
    'HTML',
    sub {
       my %args = @_;
       $args{text} =~ s/'/''/g; # quote the quotes (XPath 2.0)
       return ".//button[text()='$args{text}']";
    });

  $session->find($session->page, "@button|{text=>\"whatever\"}");

=cut

=head1 DESCRIPTION

=cut

=head1 DEPENDENCIES



=cut

package Weasel::FindExpanders;

use strict;
use warnings;

use base 'Exporter';
use Carp;

our @EXPORT_OK = qw| register_find_expander expand_finder_pattern |;

=head1 SUBROUTINES/METHODS

=over

=item register_find_expander($pattern_name, $group_name, &expander_function)

Registers C<&expander_function> as an expander for C<$pattern_name> in
C<$group_name>.

C<Weasel::Session> selects the expanders to be applied using its C<groups>
attribute.

=cut


# Stores handlers as arrays per group
my %find_expanders;

sub register_find_expander {
    my ($pattern_name, $group, $expander_function) = @_;

    return push @{$find_expanders{$group}{$pattern_name}}, $expander_function;
}

=item expand_finder_pattern($pattern, $args, $groups)

Returns a string of concatenated (using xpath '|' operator) expansions.

When C<$groups> is undef, all groups will be searched for C<pattern_name>.

If the pattern doesn't match '*<pattern_name>|{<arguments>}', the pattern
is returned as the only list/arrayref element.

=cut

sub expand_finder_pattern {
    my ($pattern, $args, $groups) = @_;

    ##no critic(ProhibitCaptureWithoutTest)
    return $pattern
        if ! ($pattern =~ m/^\*([^\|]+)/x);
    my $name = $1;
    ##critic(ProhibitCaptureWithoutTest)

    croak "No expansions registered (while expanding '$pattern')"
        if scalar(keys %find_expanders) == 0;

    $groups //= [ keys %find_expanders ];   # undef --> unrestricted
    # Using eval below to transform a hash-in-string to a hash efficiently

    my @matches;

    for my $group (@{$groups}) {
        next if ! exists $find_expanders{$group}{$name};

        push @matches,
          reverse map { $_->(%{$args}) } @{$find_expanders{$group}{$name}};
    }

    croak "No expansions matching '$pattern'"
        if ! @matches;

    return join "\n|", @matches;
}

=back

=cut

=head1 AUTHOR

Erik Huelsmann

=head1 CONTRIBUTORS

Erik Huelsmann
Yves Lavoie

=head1 MAINTAINERS

Erik Huelsmann

=head1 BUGS AND LIMITATIONS

Bugs can be filed in the GitHub issue tracker for the Weasel project:
 https://github.com/perl-weasel/weasel/issues

=head1 SOURCE

The source code repository for Weasel is at
 https://github.com/perl-weasel/weasel

=head1 SUPPORT

Community support is available through
L<perl-weasel@googlegroups.com|mailto:perl-weasel@googlegroups.com>.

=head1 LICENSE AND COPYRIGHT

 (C) 2016-2023  Erik Huelsmann

Licensed under the same terms as Perl.

=cut


1;

