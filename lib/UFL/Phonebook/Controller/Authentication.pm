package UFL::Phonebook::Controller::Authentication;

use strict;
use warnings;
use base qw/Catalyst::Controller/;

__PACKAGE__->mk_accessors(qw/authenticated_uri logout_uri/);

=head1 NAME

UFL::Phonebook::Controller::Authentication - Authentication controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for authenticating users.

=head1 METHODS

=head2 login

Redirect to the configured private area, or to the index page.

This allows you to configure a distinct URL where authentication is
handled by the Web server in test or production. When doing
development, you should modify your local configuration to simulate
the public or authenticated version of the application.

B<NOTE>: This action gives the appearance that a login is happening,
but the actual work is expected to happen elsewhere. See
L<UFL::Phonebook::Controller::Root/auto> for more information.

=cut

sub login : Global {
    my ($self, $c) = @_;

    my $authenticated_uri = $self->authenticated_uri
        || $c->uri_for($c->controller('Root')->action_for('index'));
    $c->res->redirect($authenticated_uri);
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
