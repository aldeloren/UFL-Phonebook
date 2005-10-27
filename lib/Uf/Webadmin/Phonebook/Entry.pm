package Uf::Webadmin::Phonebook::Entry;

use strict;
use warnings;
use base 'Class::Accessor';
use UNIVERSAL::require;

our $RELATIONSHIPS = {
    'uflEduAllPostalAddresses' => 'Uf::Webadmin::Phonebook::Entry::PostalAddressCollection',
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

    my $self = bless({}, (ref $class or $class));
    $self->_parse($entry);

    return $self;
}

=head2 _parse

Parse the entry's attributes and corresponding values. Basic
validation is done to avoid blank and "unknown" values.

=cut

sub _parse {
    my ($self, $entry) = @_;

    foreach my $attribute ($entry->attributes) {
        $self->attribute($attribute);
        my @values = $entry->get_value($attribute);

        if (exists $RELATIONSHIPS->{$attribute}) {
            my $class = $RELATIONSHIPS->{$attribute};
            $class->require or die $@;

            $self->$attribute($class->new(@values));
        }
        else {
            my @valid = grep { $_ and $_ ne '--UNKNOWN--' } @values;
            $self->$attribute(@valid);
        }
    }

    return $self;
}

=head2 set

Override the C<set> method from L<Class::Accessor> to push values
instead of replacing them.

=cut

sub set {
    my ($self, $key) = splice(@_, 0, 2);

    my $values = $self->get($key);

    my @new;
    push @new, @{ $values } if ref $values eq 'ARRAY';
    push @new, @_;

    $self->SUPER::set($key, @new);
}

=head2 attribute

Return a list of attributes defined on this entry.

  my @attributes = $entry->attribute

Add one or more new attributes to the list and create an accessor for
each.

  $entry->attribute('o');

=cut

sub attribute {
    my ($self, @attributes) = @_;

    if (@attributes) {
        push @{ $self->{_attributes} }, @attributes;
        $self->mk_accessors(@attributes);
    }

    return $self->{_attributes};
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
