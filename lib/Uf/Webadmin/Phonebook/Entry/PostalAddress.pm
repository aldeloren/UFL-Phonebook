package Uf::Webadmin::Phonebook::Entry::PostalAddress;

use strict;
use warnings;
use base 'Class::Accessor';
use overload
    '""' => \&as_string;

__PACKAGE__->mk_accessors(qw/title street locality region dominion postal_code/);

=head1 NAME

Uf::Webadmin::Phonebook::Entry::PostalAddress - A postal address

=head1 SYNOPSIS

  my $address = Uf::Webadmin::Phonebook::Entry::PostalAddress->new(
      <<'...'
  );
  PO BOX 112065
  GAINESVILLE, FL, US
  326112065
  ...

=head1 DESCRIPTION

This class stores a postal address, and provides convenient accessors
for each part of the address.

=head1 METHODS

=head2 new

Create a new postal address.

=cut

sub new {
    my ($class, $value) = @_;

    my $self = bless({}, (ref $class or $class));
    $self->_parse($value);

    return $self;
}

=head2 _parse

Parse the specified postal address. It is parsed in reverse:

=over 4

=item * postal code (zip code)

=item * locality (city)

=item * region (state)

=item * dominion (country)

=item * street

=item * title (any remaining lines)

=back

=cut

sub _parse {
    my ($self, $value) = @_;

    my @lines = split /\n/, $value;

    my $postal_code = pop @lines;
    $postal_code =~ s/(\d{5})(\d{4})/$1-$2/;
    $self->postal_code($postal_code);

    my ($locality, $region, $dominion) = split /,\s*/, pop @lines;
    $self->locality($locality);
    $self->region($region);
    $self->dominion($dominion);

    $self->street(pop @lines);

    # Any remaining stuff we call a 'title'
    my $title = join "\n", @lines;
    $self->title($title);
}

=head2 as_string

Return this address as a string.

=cut

sub as_string {
    my ($self) = @_;

    my @parts = (
        $self->title,
        $self->street,
        $self->locality . ', ' . $self->region . ', ' . $self->dominion,
        $self->postal_code,
    );
    my $address = join "\n", @parts;

    return $address;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;