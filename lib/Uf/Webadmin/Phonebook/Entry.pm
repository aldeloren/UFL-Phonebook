package Uf::Webadmin::Phonebook::Entry;

use strict;
use warnings;
use base 'Class::Accessor';

# Method name => uflEduAllPostalAddresses name
our $POSTAL_ADDRESS_MAPPINGS = {
    'campus'    => 'UF Business Physical Location Address',
    'mailing'   => 'UF Business Mailing Address',
    'home'      => 'Local Home Mailing Address',
    'permanent' => 'Permanent Home Mailing Address',
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

    my $values = $self->SUPER::get(@_);
    return unless $values;

    my @values = @{ $values };
    return scalar @values == 1 ? $values[0] :
        wantarray ? @values : \@values;
}

=head2 attributes

Return a list of attribute names for this phonebook entry.

=cut

sub attributes {
    my $self = shift;

    return keys %{ $self };
}

=head2 get_postal_address

Get the specified address from the C<uflEduAllPostalAddresses> field.
The address is parsed slightly to make it more human readable.

=cut

sub get_postal_address {
    my ($self, $name) = @_;

    my $postal_address = undef;

    if (my @values = $self->uflEduAllPostalAddresses) {
        foreach my $value (@values) {
            my @parts = split /\$/, $value;
            my $ldap_name = shift @parts;

            if ($POSTAL_ADDRESS_MAPPINGS->{$name} eq $ldap_name) {
                for (@parts) {
                    s/^\s+//;
                    s/\s+$//;
                }

                $postal_address = join "\n", @parts;
                $postal_address =~ s/(\d{5})(\d{4})/$1-$2/;

                last;
            }
        }
    }

    return $postal_address;
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
