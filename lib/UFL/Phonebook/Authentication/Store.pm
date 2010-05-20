package UFL::Phonebook::Authentication::Store;

use Moose;
use UFL::Phonebook::Authentication::User;

extends 'Catalyst::Authentication::Store::Null';

=head1 NAME

UFL::Phonebook::Authentication::Store - Catalyst::Plugin::Authentication store for UF Shibboleth

=head1 SYNOPSIS

    $store->find_user({ username => 'dwc@ufl.edu' });

=head1 DESCRIPTION

This is a simple wrapper for L<Catalyst::Authentication::Store::Null>
that allows us to create user objects using our own class,
L<UFL::Phonebook::Authentication::User>.

=head1 METHODS

=head2 find_user

Create a new user object based on the specific authentication
information.

=cut

around 'find_user' => sub {
    my ($orig, $self, $authinfo, $c) = @_;

    my %authinfo = %$authinfo;
    $authinfo{env} = $c->engine->env;

    my $user = UFL::Phonebook::Authentication::User->new(\%authinfo);

    return $user;
};

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
