package UFL::Phonebook::Controller::Authentication;

use strict;
use warnings;
use base qw/Catalyst::Controller/;
use URI;

__PACKAGE__->mk_accessors(qw/use_login_form use_environment authenticated_path_segments logout_uri/);

=head1 NAME

UFL::Phonebook::Controller::Authentication - Authentication controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

L<Catalyst> controller component for authentication.

=head1 METHODS

=head2 auto_login

Return true iff we are supposed to automatically authenticate users in
e.g. L<UFL::Phonebook::Controller::Root/auto>.

Currently this is true only for cases where we are using the
environment (C<REMOTE_USER>) to authenticate users.

=cut

sub auto_login {
    my ($self) = @_;

    return $self->use_environment;
}

=head2 login

Log the current user in.

=cut

sub login : Global {
    my ($self, $c) = @_;

    # Handle redirecting to a separate, authenticated URL
    if (my $authenticated_path_segments = $self->authenticated_path_segments) {
        my $authenticated_uri = URI->new($c->req->referer || $c->req->uri);
        my @path = $authenticated_uri->path_segments;
        shift @path;  # Remove initial slash
        $authenticated_uri->path_segments(@{ $authenticated_path_segments || [] }, @path);

        return $c->res->redirect($authenticated_uri);
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
            $c->stash(return_to => $c->req->param('return_to'));

            $c->detach('redirect') if $c->authenticate({
                id       => $username,
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

    # Send them back to the home page if already logged in
    return $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')))
        if $c->user_exists;

    my $username = $c->req->user;
    die "Could not determine username from environment"
        unless $username;

    $c->authenticate({
        id       => $username,
        password => $username,
    }) or die "Could not authenticate based on environment";
}

=head2 redirect

Determine where to send the user after successful login. We default to
the home page but allow specification of a C<return_to> parameter in
case the calling login method knows a better place to send the user.

=cut

sub redirect : Private {
    my ($self, $c) = @_;

    # Determine where to send the user
    my $location = $c->stash->{return_to}
        || $c->uri_for($c->controller('Root')->action_for('index'));

    return $c->res->redirect($location);
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
