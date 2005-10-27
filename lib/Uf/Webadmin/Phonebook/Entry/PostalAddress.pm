package Uf::Webadmin::Phonebook::Entry::PostalAddress;

use strict;
use warnings;
use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw/title street locality region dominion postal_code/);

=head1 NAME

Uf::Webadmin::Phonebook::Entry::PostalAddress - A postal address

=head1 SYNOPSIS



=head1 DESCRIPTION



=head1 METHODS

=head2 new



=cut

sub new {
    my ($class, $value) = @_;

    my $self = bless({}, (ref $class or $class));
    $self->_parse($value);

    return $self;
}

=head2 _parse

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
