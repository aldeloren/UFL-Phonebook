package UFL::Phonebook::Model::Person;

use strict;
use warnings;
use base qw/Catalyst::Model::LDAP/;
use Class::C3;
use Scalar::Util qw/weaken/;

=head1 NAME

UFL::Phonebook::Model::Person - LDAP Catalyst model component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst model component for L<UFL::Phonebook>.

=head1 METHODS

=head2 ACCEPT_CONTEXT

Store the current user for L<UFL::Phonebook::LDAP::Connection/bind>.

=cut

sub ACCEPT_CONTEXT {
    my $self = shift;
    my $c = $_[0];

    $self->{catalyst_user} = $c->user;
    weaken($self->{catalyst_user});

    my $conn = $self->next::method(@_);

    if ($c->user_exists) {
        # Grab the current user's LDAP record
        my $mesg = $conn->search("uid=" . $c->user->id);
        if ($mesg->entries) {
            $c->user->ldap_record($mesg->shift_entry);
        }
    }

    return $conn;
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
