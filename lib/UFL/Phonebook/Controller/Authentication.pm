package UFL::Phonebook::Controller::Authentication;

use strict;
use warnings;
use base qw/Catalyst::Controller/;
use URI;

__PACKAGE__->mk_accessors(qw/use_login_form use_environment authenticated_uri logout_uri/);

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
    if ($self->authenticated_uri) {
        $c->res->cookies->{referer} = { value => $c->req->referer };

        my $authenticated_uri = $c->uri_for($self->authenticated_uri);
        return $c->res->redirect($authenticated_uri)
            unless $c->req->uri =~ /^$authenticated_uri/;
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

    my $username = $c->req->user;
    die "Could not determine username from environment"
        unless $username;

    $c->authenticate({
        username => $username,
        password => $username,
    }) or die "Could not authenticate based on environment";

    # Determine where to send the user
    my $return_to = $c->req->referer;

    # For separate, authenticated URL case
    my $cookie = $c->req->cookies->{referer};
    if ($cookie and $cookie->value) {
        $return_to = $cookie->value;
        $c->res->cookies->{referer} = { value => '' };
    }

    $c->stash(return_to => $return_to);

    $c->forward('redirect');
}

=head2 redirect

Determine where to send the user after successful login. We check for
a C<referer> cookie for returning the user to the authenticated view
of the previous page.

=cut

sub redirect : Private {
    my ($self, $c) = @_;

    # Determine where to send the user
    my $location = $c->uri_for($c->controller('Root')->action_for('index'));

    my $return_to = $c->stash->{return_to};
    if ($return_to) {
        # Build a new, authenticated URL based on the anonymous referer URL
        my $uri = URI->new($return_to);
        $location = $c->uri_for($uri->path, { $uri->query_form });
    }

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
