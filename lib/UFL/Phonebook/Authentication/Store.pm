package UFL::Phonebook::Authentication::Store;

use Moose;
use UFL::Phonebook::Authentication::User;

=head1 NAME

UFL::Phonebook::Authentication::Store - Catalyst::Plugin::Authentication store for UF Shibboleth

=head1 SYNOPSIS

    $store->find_user({ username => 'dwc@ufl.edu' });

=head1 DESCRIPTION

A C<Catalyst::Authentication::Store> that returns
L<UFL::Phonebook::Authentication::User> objects, possibly with
additional information applied.

=head1 ATTRIBUTES

=head2 extra_authinfo

Additional authentication information that should be applied to users
who login. For example:

    $store->extra_authinfo({
        'dwc@ufl.edu' => { roles => [ qw/admin/ ] },
    });

This would add the C<admin> role to the
L<UFL::Phonebook::Authentication::User> object corresponding to
C<dwc@ufl.edu>.

=cut

has 'extra_authinfo' => (is => 'rw', isa => 'HashRef', default => sub { {} });

=head1 METHODS

=head2 BUILDARGS

=cut

around 'BUILDARGS' => sub {
    my ($orig, $class, $config, $c, $realm) = @_;

    return $class->$orig(%{ $config });
};

=head2 find_user

Create a new user object based on the specific authentication
information.

=cut

sub find_user {
    my ($self, $authinfo, $c) = @_;

    my %authinfo = %$authinfo;
    $authinfo{env} = $c->engine->env;

    if (my $extra_authinfo = $self->extra_authinfo->{$authinfo{username}}) {
        @authinfo{keys %$extra_authinfo} = values %$extra_authinfo;
    }

    my $user = UFL::Phonebook::Authentication::User->new(\%authinfo);

    return $user;
}

=head2 for_session

Return a serializable user object.

=cut

sub for_session {
    my ($self, $c, $user) = @_;

    return $user;
}

=head2 from_session

Restore a user object from serialized data.

=cut

sub from_session {
    my ($self, $c, $user) = @_;

    return $user;
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
