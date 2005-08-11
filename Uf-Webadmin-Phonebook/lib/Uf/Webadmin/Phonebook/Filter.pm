package Uf::Webadmin::Phonebook::Filter;

use strict;

=head1 NAME

Uf::Webadmin::Phonebook::Filter - An abstract LDAP filter

=head1 SYNOPSIS

  my $filter = Uf::Webadmin::Phonebook::Filter->new(
    cn => 'Test,*',
  );
  print $filter->toString;

=head1 DESCRIPTION

An abstract representation of an LDAP filter.

=head1 METHODS

=head2 new



=cut

sub new {
    my ($class, %spec) = @_;

    my $self = bless({}, $class);
    $self->{spec} = \%spec;

    return $self;
}

=head2 toString

Return a string represenation of this filter. Optionally, the logical
operator can be specified (e.g. '|' or '&').

=cut

sub toString {
    my ($self, $operator) = @_;

    $operator ||= '|';

    my %spec = %{ $self->{spec} };
    my $string = "($operator" . join('', map { '(' . $_ . '=' . $spec{$_} . ')' } keys %spec) . ')';

    return $string;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
