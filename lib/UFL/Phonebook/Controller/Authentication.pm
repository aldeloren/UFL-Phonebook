package UFL::Phonebook::Controller::Authentication;

use strict;
use warnings;
use base qw/Catalyst::Controller/;

__PACKAGE__->mk_accessors(qw/redirect_to use_login_form use_environment logout_uri/);

=head1 NAME

UFL::Phonebook::Controller::Authentication - Authentication controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

L<Catalyst> controller component for authentication.

=head1 METHODS

=head2 login

Log the current user in.

=cut

sub login : Global {
    my ($self, $c) = @_;

    # Allow redirection to a separate, authenticated URL
    if ($self->redirect_to) {
        my $redirect_to = $c->uri_for($self->redirect_to);
        return $c->res->redirect($redirect_to)
            unless $c->req->uri =~ /^$redirect_to/;
    }

    if ($self->use_login_form) {
        $c->forward('login_via_form');
    }
    elsif ($self->use_environment) {
        $c->forward('login_via_env');
    }
    else {
        die 'Could not log you in';
    }

    return $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')))
        if $c->user_exists;
}

=head2 login_via_form

Log the user in via a standard username and password form.

=cut

sub login_via_form : Private {
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

        $c->stash(authentication_error => 1) unless $c->user_exists;
    }

    $c->stash(template => 'authentication/login.tt');
}

=head2 login_via_env

Log the user in based on the environment (via C<REMOTE_USER>).

=cut

sub login_via_env : Private {
    my ($self, $c) = @_;

    my $username = $c->request->user;
    die "Could not determine username from environment"
        unless $username;

    $c->authenticate({
        username => $username,
        password => $username,
    }) or die "Could not authenticate based on environment";
}

=head2 logout

Logout the current user.

=cut

sub logout : Global {
    my ($self, $c) = @_;

    $c->logout;

    my $logout_uri = $self->logout_uri
        || $c->uri_for($c->controller('Root')->action_for('index'));
    $c->res->redirect($logout_uri);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
