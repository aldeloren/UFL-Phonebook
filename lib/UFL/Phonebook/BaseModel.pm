package UFL::Phonebook::BaseModel;

use strict;
use warnings;
use base qw/Catalyst::Model::LDAP/;
use Class::C3;

=head1 NAME

UFL::Phonebook::BaseModel - Base LDAP Catalyst model component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Base Catalyst model component for L<UFL::Phonebook>.

=head1 METHODS

=head2 ACCEPT_CONTEXT

Store the current user for L<UFL::Phonebook::LDAP::Connection/search>.

=cut

sub ACCEPT_CONTEXT {
    my $self = shift;
    my $c = $_[0];

    my $conn = $self->next::method(@_);

    if ($conn->can('catalyst_user') and $c->user_exists) {
        $conn->catalyst_user($c->user);
    }

    return $conn;
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
