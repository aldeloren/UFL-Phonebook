package UFL::Phonebook::Model::Throttle;

use strict;
use warnings;
use Data::Throttler;
use DateTime;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

__PACKAGE__->config(
    # Set default limit to one request every two seconds
    throttler_options => {
        max_items => 1800,
        interval  => 3600,
    },
);

=head1 NAME

UFL::Phonebook::Model::Throttle - Model for throttling IPs

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst model component for throttling IP addresses.

=head1 ATTRIBUTES

=head2 throttler_options

A hash reference containing options for L<Data::Throttler>.

=head2 throttled_ips

A hash reference containing IP address that have been throttled and
the corresponding date and time.

=head2 _throttler

The L<Data::Throttler> object.

=cut

# Default is set via config to take advantage of the merge behavior in
# Catalyst::Component
has 'throttler_options' => (
    is  => 'rw',
    isa => 'HashRef',
);

has 'throttled_ips' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

has '_throttler' => (
    is      => 'rw',
    isa     => 'Data::Throttler',
    lazy    => 1,
    builder => '_build_throttler',
);

=head1 METHODS

=head2 _build_throttler

Build a new L<Data::Throttler> object for use in L</check>.

=cut

sub _build_throttler {
    my ($self) = @_;

    my $throttler = Data::Throttler->new(%{ $self->throttler_options || {} });

    return $throttler;
}

=head2 allow

Check if the specified IP address has made too many requests
recently. This behavior is configurable using the C<throttler_options>
parameter. For example:

  throttler_options:
    max_items: 100
    interval:  3600

This allows a given key to make 100 requests per hour. If this limit
is exceeded, this method will return false.

For more information on what can go in the C<throttler_options>
parameter, see the L<Data::Throttler> documentation.

=cut

sub allow {
    my ($self, $ip) = @_;

    return 1 if $self->_throttler->try_push(key => $ip)
        and not exists $self->throttled_ips->{$ip};

    # User is throttled
    $self->add($ip);

    return 0;
}

=head2 add

Add the specified IP address to the list of throttled IPs.

=cut

sub add {
    my ($self, $ip) = @_;

    $self->throttled_ips->{$ip} = DateTime->now(time_zone => 'local')
        unless exists $self->throttled_ips->{$ip};
}

=head2 remove

Remove the specified IP address from the list of throttled IPs.

=cut

sub remove {
    my ($self, $ip) = @_;

    $self->_throttler->reset_key(key => $ip);
    delete $self->throttled_ips->{$ip};
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
