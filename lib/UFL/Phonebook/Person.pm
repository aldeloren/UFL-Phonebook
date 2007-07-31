package UFL::Phonebook::Person;

use strict;
use warnings;
use base qw/UFL::Phonebook::Entry/;
use UFL::Phonebook::Util;

=head1 NAME

UFL::Phonebook::Person - A person phonebook entry

=head1 SYNOPSIS

    # Search using Net::LDAP
    my $mesg = $ldap->search($filter);
    my @entries = map {
        UFL::Phonebook::Person->new($_)
    } $mesg->entries;
    print $entries[0]->uid;

=head1 DESCRIPTION

A person in the directory.

=head1 METHODS

=head2 uri_args

Return the list of URL path arguments needed to identify this person.

=cut

sub uri_args {
    my ($self) = @_;

    return [ UFL::Phonebook::Util::encode_ufid($self->uflEduUniversityId) ];
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
