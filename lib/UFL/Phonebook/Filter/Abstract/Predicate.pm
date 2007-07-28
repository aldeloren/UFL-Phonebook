package UFL::Phonebook::Filter::Abstract::Predicate;

use strict;
use base qw/Tree::Simple/;

=head1 NAME

UFL::Phonebook::Filter::Abstract::Predicate - An LDAP predicate

=head1 SYNOPSIS

See L<UFL::Phonebook::Filter::Abstract>.

=head1 DESCRIPTION

An LDAP predicate, which might look like:

    (sn=Test)

This class is not intended to be used directly. See
L<UFL::Phonebook::Filter::Abstract>.

=head1 METHODS

=head2 new

Create a new LDAP predicate node.

    my $predicate = UFL::Phonebook::Filter::Abstract::Predicate->new(qw/sn = Test/);

=cut

sub new {
    my $class = shift;

    if (scalar @_ != 3) {
        warn 'Possibly invalid predicate: ' . join ', ', @_;
    }
    my $predicate = join('', @_);
    my $self = (ref($class) || $class)->SUPER::new($predicate);

    return $self;
}

=head2 as_string

Generate the LDAP filter string for this predicate. Predicates cannot
have child nodes, so this is simple.

=cut

sub as_string {
    my $self = shift;

    my $string = '(' . $self->getNodeValue. ')';

    return $string;
}

=head1 SEE ALSO

L<UFL::Phonebook::Filter::Abstract>

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
