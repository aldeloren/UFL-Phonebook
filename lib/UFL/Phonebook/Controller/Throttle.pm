package UFL::Phonebook::Controller::Throttle;

use strict;
use warnings;
use base qw/Catalyst::Controller/;
use Data::Throttler;
use DateTime;
use MRO::Compat;

__PACKAGE__->config(
    # Set default limit to one request every two seconds
    throttler_options => {
        max_items => 1800,
        interval  => 3600,
    },
    throttle_enabled => 1,
);

__PACKAGE__->mk_accessors(qw/
    throttler_options
    throttle_enabled
    _throttler
    _throttled_ips
/);

=head1 NAME

UFL::Phonebook::Controller::Throttle - Controller for managing throttled IPs

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for managing throttled IP addresses.

=head1 METHODS

Build a new controller, including a L<Data::Throttler> object for use
in L</throttle>.

=head2 new

=cut

sub new {
    my $self = shift->next::method(@_);

    my $throttler = Data::Throttler->new(%{ $self->throttler_options || {} });
    $self->_throttler($throttler);

    $self->_throttled_ips({});

    return $self;
}

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
        ips      => $self->_throttled_ips,
        options  => $self->throttler_options,
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
            $self->_throttler->reset_key(key => $ip);
            delete $self->_throttled_ips->{$ip};
        }
    }

    $c->res->redirect($c->uri_for($self->action_for('index')));
}

=head2 check

Throttle the user if he or she has made too many requests
recently. This behavior is configurable per controller, using the
C<throttler_options> parameter. For example:

  throttler_options:
    max_items: 100
    interval:  3600

This allows a given IP address to make 100 requests per hour. If this
limit is exceeded, a the user receives a 503 Service Unavailable
response.

For more information on what can go in the C<throttler_options>
parameter, see the L<Data::Throttler> documentation.

=cut

sub check : Private {
    my ($self, $c) = @_;

    my $ip = $c->req->address;
    if ($self->throttle_enabled and not $self->_throttler->try_push(key => $ip)) {
        $c->log->info("Throttling request from [$ip]");

        $self->_throttled_ips->{$ip} = DateTime->now(time_zone => 'local')
            unless exists $self->_throttled_ips->{$ip};

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
