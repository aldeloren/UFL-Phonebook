package Uf::Webadmin::Phonebook::Filter;

use strict;
use Data::Dumper;
use Scalar::Util qw(blessed);

=head1 NAME

Uf::Webadmin::Phonebook::Filter - An abstract LDAP filter

=head1 SYNOPSIS

  my $filter = Uf::Webadmin::Phonebook::Filter->new('|', {
      cn => 'Test,*'
  });
  print $filter->toString;

=head1 DESCRIPTION

An abstract representation of an LDAP filter.

=head1 METHODS

=head2 new

Create a new abstract filter. The operator can be one defined in
L<Net::LDAP::Filter>. C<@spec> is a list of hashrefs or
L<Uf::Webadmin::Phonebook::Filter> objects.

=cut

sub new {
    my ($class, $operator, @spec) = @_;

    my $self = bless({}, (ref $class or $class));

    $self->{operator} = $operator;
    $self->{spec} = \@spec;

    return $self;
}

=head2 toString

Return a string represenation of this filter.

=cut

sub toString {
    my ($self) = @_;

    my $operator = $self->{operator};
    my @spec = @{ $self->{spec} };

    my @parts = map {
        if (blessed $_ and $_->isa(__PACKAGE__)) {
            $_->toString;
        }
        else {
            my %table = %{ $_ };
            map {
                if (ref $table{$_} eq 'ARRAY') {
                    my $field = $_;
                    map { _filter($field, $_) } @{ $table{$_} };
                }
                else {
                    _filter($_, $table{$_});
                }
            } keys %table;
        }
    } @spec;

    # Build the filter string, adding the operator if necessary
    my $string = join('', @parts);
    if (scalar @parts > 1) {
        $string = "($operator$string)";
    }

    return $string;
}

=head2 _filter

Given a field and value, return the LDAP filter string.

=cut

sub _filter {
    my ($field, $value) = @_;

    return "($field=$value)";
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
