package UFL::Phonebook::Plugin::Authentication::Store::AnyUser;

use strict;
use warnings;
use base qw/Catalyst::Plugin::Authentication::Store::Minimal/;
use Catalyst::Plugin::Authentication::User::Hash;

=head1 NAME

UFL::Phonebook::Authentication::Store::AnyUser - Allow any user to authenticate

=head1 SYNOPSIS

See L<Catalyst::Plugin::Authentication::Internals>.

=head1 DESCRIPTION

A simple store that allows any user to authenticate.  This is useful
for situations where your authentication is handled externally.

When used in conjunction with a flexible authentication controller,
for example, you can use this to authenticate based on the
C<REMOTE_USER> environment variable.  This is often set in Apache
authentication modules.

=head1 METHODS

=head2 find_user

Return a new L<Catalyst::Plugin::Authentication::User::Hash> object
for the specified username.

=cut

sub find_user {
    my ($self, $authinfo, $c) = @_;

    my $id = $authinfo->{id} || $authinfo->{username};
    die 'No username specified' unless $id;

    return Catalyst::Plugin::Authentication::User::Hash->new(
        id       => $id,
        password => $id,
    );
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
