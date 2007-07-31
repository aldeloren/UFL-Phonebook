package UFL::Phonebook::Unit;

use strict;
use warnings;
use base qw/UFL::Phonebook::Entry/;

=head1 NAME

UFL::Phonebook::Unit - A unit phonebook entry

=head1 SYNOPSIS

    # Search using Net::LDAP
    my $mesg = $ldap->search($filter);
    my @entries = map {
        UFL::Phonebook::Unit->new($_)
    } $mesg->entries;
    print $entries[0]->o;

=head1 DESCRIPTION

A unit or organization in the directory.

=head1 METHODS

=head2 uri_args

Return the list of URL path arguments needed to identify this unit.

=cut

sub uri_args {
    my ($self) = @_;

    return [ $self->uflEduPsDeptId ];
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
