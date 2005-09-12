package Uf::Webadmin::Phonebook::Entry;

use strict;
use base 'Class::Accessor';
use Data::Dumper;

our $ADDRESS_MAPPINGS = {
    'UF Business Physical Location Address' => 'campusAddress',
    'UF Business Mailing Address'           => 'mailingAddress',
    'Local Home Mailing Address'            => 'homeAddress',
    'Permanent Home Mailing Address'        => 'permanentAddress',
};

=head1 NAME

Uf::Webadmin::Phonebook::Entry - A phonebook entry

=head1 SYNOPSIS

  # Search using Net::LDAP
  my $mesg = $ldap->search($filter);
  my @entries = map {
      Uf::Webadmin::Phonebook::Entry->new($_)
  } $mesg->entries;
  print $entries[0]->eduPersonPrimaryAffiliation;

=head1 DESCRIPTION

Exposes attributes from a L<Net::LDAP::Entry> as instance variables,
so repeated calls to C<get_value> are not necessary.

=head1 METHODS

=head2 new

Given a L<Net::LDAP::Entry>, create our view of that entry.

=cut

sub new {
    my ($class, $entry) = @_;

    return unless $entry;

    my $self = bless({}, (ref $class or $class));

    foreach my $attribute ($entry->attributes) {
        my @values = $entry->get_value($attribute);
        $self->_store($attribute, @values);
    }

    return $self;
}

=head2 _store

Store an attribute and its values. Basic validation is done to avoid
blank and "unknown" values.

=cut

sub _store {
    my ($self, $attribute, @values) = @_;

    foreach my $value (@values) {
        if ($value and $value ne '--UNKNOWN--') {
            push @{ $self->{$attribute} }, $value;
        }
    }

    $self->mk_ro_accessors($attribute);
}

=head2 get

Override the C<get> method from L<Class::Accessor> to provide scalar
values by default. If the LDAP entry contained multiple values,
provide a list or an arrayref, depending on context.

=cut

sub get {
    my $self = shift;

    if (my $values = $self->SUPER::get(@_)) {
        my @values = @{ $values };
        if (scalar @values == 1) {
            return $values[0];
        }
        else {
            return wantarray ? @values : \@values;
        }
    }

    return undef;
}

=head2 attributes

Return a list of attribute names for this phonebook entry.

=cut

sub attributes {
    my $self = shift;

    return keys %{ $self };
}

=head1 TODO

=over 4

=item *

It might make more sense if this package were in the
C<Uf::Webadmin::Phonebook::M> namespace, but I see that more for
L<Catalyst> model pieces.

=back

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
