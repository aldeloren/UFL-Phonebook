package UFL::Phonebook::Authentication::User;

use Moose;
use UFL::Phonebook::Util;

extends 'Catalyst::Authentication::User';

=head1 NAME

UFL::Phonebook::Authentication::User - Catalyst::Plugin::Authentication user for UF Shibboleth

=head1 SYNOPSIS

    my $user = UFL::Phonebook::Authentication::User->new({ username => 'dwc@ufl.edu', env => $c->engine->env });

=head1 DESCRIPTION

This is a simple wrapper for L<Catalyst::Authentication::Store::Null>
that allows us to create user objects using our own class,
L<UFL::Phonebook::Authentication::User>.

=head1 ATTRIBUTES

=head2 username

The user's normal identifier, e.g. C<dwc@ufl.edu>.

=head2 env

Stores the user's environment as of login time.

=cut

has 'username' => (is => 'rw', isa => 'Str', required => 1);
has 'env'      => (is => 'rw', isa => 'HashRef', required => 1);

=head1 METHODS

=head2 id

Override L<Catalyst::Authentication::User/id> to return the username.

=cut

override 'id' => sub {
    my ($self) = @_;

    return $self->username;
};

=head2 ldap_username

Return the username used for proxy authentication in
L<UFL::Phonebook::LDAP::Connection/search>.

=cut

sub ldap_username {
    my ($self) = @_;

    return $self->env->{glid};
}

=head2 display_name

Return a human-friendly display name. This is the common name if we
have it; otherwise, we return the username.

=cut

sub display_name {
    my ($self) = @_;

    return $self->env->{cn} || $self->username;
}

=head2 primary_affiliation

Return the user's primary affiliation, e.g. student or faculty.

=cut

sub primary_affiliation {
    my ($self) = @_;

    return $self->env->{primary_affiliation};
}

=head2 uri_args

Return the list of URL path arguments needed to identify this user.

=cut

sub uri_args {
    my ($self) = @_;

    return [ UFL::Phonebook::Util::encode_ufid($self->env->{ufid}) ];
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
