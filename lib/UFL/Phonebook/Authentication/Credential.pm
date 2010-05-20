package UFL::Phonebook::Authentication::Credential;

use Moose;

has 'source' => (is => 'rw', isa => 'Str', default => 'REMOTE_USER');
has 'realm'  => (is => 'rw', isa => 'Ref');

=head1 NAME

UFL::Phonebook::Authentication::Credential - Catalyst::Plugin::Authentication credential for UF Shibboleth

=head1 SYNOPSIS

    # In MyApp.pm
    __PACKAGE__->config(
        'Plugin::Authentication' => {
            default_realm => 'myrealm',
            realms => {
                myrealm => {
                    store => {
                        class => '...',
                    },
                    credential => {
                        class => '+UFL::Phonebook::Authentication::Credential',
                    },
                },
            },
        },
    );

    # In your root controller, to implement automatic login
    sub begin : Private {
        my ($self, $c) = @_;
        unless ($c->user_exists) {
            unless ($c->authenticate()) {
                # Return a 403 Forbidden status
            }
        }
    }

    # Or you can use an ordinary login action
    sub login : Global {
        my ($self, $c) = @_;
        $c->authenticate();
    }

=head1 DESCRIPTION

This module allows you to authenticate users via arbitrary keys in the
environment.  It is similar to
L<Catalyst::Authentication::Credential::Remote>, but does not have any
restriction on which fields can be used to determine the username.

This allows it to be used in conjunction with Shibboleth.

=head1 CONFIGURATION

=head2 class

(Required) Part of the core L<Catalyst::Plugin::Authentication>
module. This must be set to
C<+UFL::Phonebook::Authentication::Credential> for this module to be
used.

=head2 source

(Optional) Specifies the environment variable passed from the external
authentication setup that contains the username.

By default, this is set to C<REMOTE_USER>.

=head1 ATTRIBUTES

=head2 source

The environment variable passed from the external authentication setup
that contains the username.

=head2 realm

The C<Catalyst::Authentication::Realm> object used to find users.

=head1 METHODS

=head2 BUILDARGS

Add the configured realm to the configuration hash.

=cut

around 'BUILDARGS' => sub {
    my ($orig, $class, $config, $c, $realm) = @_;

    return $class->$orig(%{ $config }, realm => $realm);
};

=head2 authenticate

Take the username from the environment and attempt to find a user.

=cut

sub authenticate {
    my ($self, $c, $realm, $authinfo) = @_;

    my $env = $c->engine->env;

    my $source = $self->source;
    my $remote_user = $env->{$source};
    return if not defined $remote_user or $remote_user eq '';

    # Support having a username specified in the call to $c->authenticate
    my $auth_user = $authinfo->{username};
    return if defined $auth_user and $auth_user ne $remote_user;

    $authinfo->{username} = $remote_user;

    my $user_obj = $realm->find_user($authinfo, $c);
    $c->log->debug($user_obj ? "Authenticated user via Shibboleth: username = [" . $user_obj->username . "]" : "Did not find user via Shibboleth");

    return $user_obj;
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
