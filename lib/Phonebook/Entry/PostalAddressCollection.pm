package Phonebook::Entry::PostalAddressCollection;

use strict;
use warnings;
use base 'Class::Accessor';
use overload
    '""' => \&as_string;
use Phonebook::Entry::PostalAddress;

# uflEduAllPostalAddresses name => External name
our $MAPPINGS = {
    'UF Business Physical Location Address' => 'campus',
    'UF Business Mailing Address'           => 'mailing',
    'Local Home Mailing Address'            => 'home',
    'Permanent Home Mailing Address'        => 'permanent',
    'Housing Address'                       => 'housing',
    'Emergency Contact'                     => 'emergency',
};

__PACKAGE__->mk_accessors(values %{ $MAPPINGS }, '_original');

=head1 NAME

Phonebook::Entry::PostalAddressCollection - A collection of postal addresses

=head1 SYNOPSIS

  my $addresses = Phonebook::Entry::PostalAddressCollection->(
      'UF Business Mailing Address$PO BOX 112065$GAINESVILLE, FL, US$ 326112065'
  );
  print $addresses->campus;

=head1 DESCRIPTION

This class stores a collection of postal addresses.

=head1 METHODS

=head2 new

Create a new postal address collection, containing the parsed version
of each of the specified addresses from LDAP.

=cut

sub new {
    my ($class, @values) = @_;

    my $self = bless({}, (ref $class or $class));

    $self->_original([ @values ]);

    foreach my $value (@values) {
        eval {
            my ($name, $address) = $self->_parse($value);
            $self->$name($address);
        };
        if (my $error = $@) {
            warn $error;
        }
    }

    return $self;
}

=head2 _parse

Parse the specified address into a
L<Phonebook::Entry::PostalAddress>. If the address cannot be parsed,
an exception is thrown.

=cut

sub _parse {
    my ($self, $value) = @_;

    my @parts      = split /\$/, $value;
    my $ldap_name  = shift @parts;
    my $ldap_value = join '$', @parts;

    die "Unknown address type: [$value]"
        unless exists $MAPPINGS->{$ldap_name};

    my $name    = $MAPPINGS->{$ldap_name};
    my $address = Phonebook::Entry::PostalAddress->new($ldap_value);

    return ($name, $address);
}

=head2 as_string

Return the original LDAP postal address data as a string.

=cut

sub as_string {
    my ($self) = @_;

    my $string = join "\n", @{ $self->_original };

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
