package UFL::Phonebook::Controller::Authentication;

use strict;
use warnings;
use base qw/Catalyst::Controller/;

=head1 NAME

UFL::Phonebook::Controller::Authentication - Authentication controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

L<Catalyst> controller component for authentication.

=head1 METHODS

=head2 login

Login the current user.

=cut

sub login : Global {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        my $username = $c->req->param('username');
        my $password = $c->req->param('password');

        if ($username and $password) {
            $c->authenticate({
                username => $username,
                password => $password,
            });
        }

        return $c->res->redirect($c->uri_for('/')) if $c->user_exists;

        $c->stash(authentication_error => 'Invalid username or password');
    }

    $c->stash(template => 'authentication/login.tt');
}

=head2 logout

Logout the current user.

=cut

sub logout : Global {
    my ($self, $c) = @_;

    $c->logout;

    my $logout_uri = $c->config->{logout_uri} || $c->uri_for('/');
    $c->res->redirect($logout_uri);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
