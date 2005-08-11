package Uf::Webadmin::Phonebook::Filter;

use strict;

=head1 NAME

Uf::Webadmin::Phonebook::Filter - An abstract LDAP filter

=head1 SYNOPSIS

  my $filter = Uf::Webadmin::Phonebook::Filter->new(
    cn => 'Test,*'
  );
  print $filter->toString;

=head1 DESCRIPTION

An abstract representation of an LDAP filter.

=head1 METHODS

=head2 new

Create a new abstract filter. Each key-value pair in C<$spec> is a
mapping from attribute to filter value. Optionally, the logical
operator to use in combining filters can be specified. The default is
C<|>.

=cut

sub new {
    my ($class, $spec, $operator) = @_;

    my $self = bless({}, (ref $class or $class));

    $self->{spec}  = $spec;
    $self->{operator} = $operator || '|';

    return $self;
}

=head2 toString

Return a string represenation of this filter.

=cut

sub toString {
    my ($self) = @_;

    my $operator = $self->{operator};
    my %spec = %{ $self->{spec} };

    my $string = "($operator" . join('', map { '(' . $_ . '=' . $spec{$_} . ')' } keys %spec) . ')';

    return $string;
}

=head1 TODO

=over 4

=item *

Extend representation of to allow specification of more complex
filters.

=item *

Handle cases where only one filter is specified - the operator isn't
necessary.

=back

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
