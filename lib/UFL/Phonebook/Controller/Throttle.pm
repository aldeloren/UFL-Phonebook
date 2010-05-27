package UFL::Phonebook::Controller::Throttle;

use strict;
use warnings;
use base qw/Catalyst::Controller/;

__PACKAGE__->mk_accessors(qw/throttle_enabled/);

__PACKAGE__->config(throttle_enabled => 1);

=head1 NAME

UFL::Phonebook::Controller::Throttle - Controller for managing throttled IPs

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for managing throttled IP addresses.

=head1 METHODS

=head2 auto

Require authentication for the throttle administration screens.

=cut

sub auto : Private {
    my ($self, $c) = @_;

    $c->forward('/forbidden') and return 0
        unless $c->authenticate() and $c->check_user_roles('admin');

    return 1;
}

=head2 index

Display a list of throttled IPs for administrators.

=cut

sub index : Path('') Args(0) {
    my ($self, $c) = @_;

    $c->stash(
        ips      => $c->model('Throttle')->throttled_ips,
        options  => $c->model('Throttle')->throttler_options,
        template => 'throttle/index.tt',
    );
}

=head2 remove

Remove the specified IP from the list of throttled addresses.

=cut

sub remove : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if (my $ip = $c->req->params->{ip}) {
            $c->log->info("Removing [$ip] from throttle list");
            $c->model('Throttle')->remove($ip);
        }
    }

    $c->res->redirect($c->uri_for($self->action_for('index')));
}

=head2 check

Throttle the user if he or she has made too many requests
recently. This behavior is configurable using
L<UFL::Phonebook::Model::Throttle>.

If the configured limit is exceeded, a the user receives a 503 Service
Unavailable response.

=cut

sub check : Private {
    my ($self, $c) = @_;

    my $ip = $c->req->address;
    if ($self->throttle_enabled and not $c->model('Throttle')->allow($ip)) {
        $c->log->info("Throttling request from [$ip]");
        $c->detach('/unavailable');
    }
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
