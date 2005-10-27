package Uf::Webadmin::Phonebook::Entry::PostalAddressCollection;

use strict;
use warnings;
use base 'Class::Accessor';
use Uf::Webadmin::Phonebook::Entry::PostalAddress;

# uflEduAllPostalAddresses name => External name
our $MAPPINGS = {
    'UF Business Physical Location Address' => 'campus',
    'UF Business Mailing Address'           => 'mailing',
    'Local Home Mailing Address'            => 'home',
    'Permanent Home Mailing Address'        => 'permanent',
};

__PACKAGE__->mk_accessors(values %{ $MAPPINGS });

=head1 NAME

Uf::Webadmin::Phonebook::Entry::PostalAddressCollection - A collection of postal addresses

=head1 SYNOPSIS



=head1 DESCRIPTION



=head1 METHODS

=head2 new



=cut

sub new {
    my ($class, @values) = @_;

    my $self = bless({}, (ref $class or $class));

    foreach my $value (@values) {
        my ($name, $address) = $self->_parse($value);
        $self->$name($address);
    }

    return $self;
}

=head2 _parse



=cut

sub _parse {
    my ($self, $value) = @_;

    my @parts = split /\$/, $value;
    my $ldap_name = shift @parts;

    for (@parts) {
        s/^\s+//;
        s/\s+$//;
    }

    my $string = join "\n", @parts;

    my $name    = $MAPPINGS->{$ldap_name};
    my $address = Uf::Webadmin::Phonebook::Entry::PostalAddress->new($string);

    return ($name, $address);
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
