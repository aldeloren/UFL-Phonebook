package UFL::Phonebook::Entry;

use strict;
use warnings;
use base qw/Catalyst::Model::LDAP::Entry/;
use Class::C3;

our $RELATIONSHIPS = {
    postalAddress            => 'UFL::Phonebook::Entry::PostalAddress',
    registeredAddress        => 'UFL::Phonebook::Entry::PostalAddress',
    street                   => 'UFL::Phonebook::Entry::PostalAddress',
    uflEduAllPostalAddresses => 'UFL::Phonebook::Entry::PostalAddressCollection',
    uflEduOfficeLocation     => 'UFL::Phonebook::Entry::PostalAddress',
};

=head1 NAME

UFL::Phonebook::Entry - A phonebook entry

=head1 SYNOPSIS

    # Search using Net::LDAP
    my $mesg = $ldap->search($filter);
    my @entries = map {
        UFL::Phonebook::Entry->new($_)
    } $mesg->entries;
    print $entries[0]->eduPersonPrimaryAffiliation;

=head1 DESCRIPTION

Parses the postal addresses on the associated LDAP entry.

=head1 METHODS

=head2 new

Given a L<Net::LDAP::Entry>, create our view of that entry.

=cut

sub new {
    my $self = shift->next::method(@_);

    foreach my $attribute ($self->attributes) {
        my @values = $self->get_value($attribute);

        if (exists $RELATIONSHIPS->{$attribute}) {
            my $class = $RELATIONSHIPS->{$attribute};
            eval "require $class"; die $@ if $@;

            $self->$attribute([ $class->new(@values) ]);
        }
        else {
            my @valid = grep { $_ and $_ ne '--UNKNOWN--' } @values;
            $self->$attribute(\@valid);
        }
    }

    return $self;
}

=head2 get_url_args

Return the list of URL path arguments needed to identify this entry.

=cut

sub get_url_args {
    my ($self) = @_;

    return $self->uflEduUniversityId;
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
