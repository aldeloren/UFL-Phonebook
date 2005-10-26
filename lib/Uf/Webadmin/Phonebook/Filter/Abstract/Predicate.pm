package Uf::Webadmin::Phonebook::Filter::Abstract::Predicate;

use strict;
use base 'Tree::Simple';

=head1 NAME

Uf::Webadmin::Phonebook::Filter::Abstract::Predicate - An LDAP predicate

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook::Filter::Abstract>.

=head1 DESCRIPTION

An LDAP predicate, which might look like:

  (sn=Test)

This class is not intended to be used directly. See
L<Uf::Webadmin::Phonebook::Filter::Abstract>.

=head1 METHODS

=head2 new

Create a new LDAP predicate node.

  my $predicate = Uf::Webadmin::Phonebook::Filter::Abstract::Predicate->new(qw/sn = Test/);

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

Generate the LDAP filter string for this predicate. Predicates can't
have child nodes, so this is simple.

=cut

sub as_string {
    my $self = shift;

    my $string = '(' . $self->getNodeValue. ')';

    return $string;
}

=head1 SEE ALSO

L<Uf::Webadmin::Phonebook::Filter::Abstract>

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
