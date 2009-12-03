package UFL::Phonebook::LDAP::Connection;

use strict;
use warnings;
use base qw/Catalyst::Model::LDAP::Connection/;
use Authen::SASL qw/Perl/;
use Carp qw/croak/;
use MRO::Compat;
use Net::LDAP::Control::ProxyAuth;

__PACKAGE__->mk_accessors(qw/catalyst_user/);

=head1 NAME

UFL::Phonebook::LDAP::Connection - LDAP connection for authenticated requests

=head1 DESCRIPTION

Overrides L<Catalyst::Model::LDAP::Connection> to run LDAP searches as
the person associated with the current L<Catalyst> user.

The connection uses Kerberos to authenticate as an
application-specific account that has the authority to assume the
identity of other users.

An external command, C<kinit>, is used to get a ticket from the
Kerberos server. The ticket is only refreshed when needed, based on
the mtime of the ticket cache file.

Occasionally the Kerberos ticket will become invalid. This problem
often shows up as the following error:

    LDAP error: Local error

If this happens, check that there is a valid Kerberos ticket for the
user running the code and make sure that the ticket cache path as
configured for this connection is correct.

=head1 METHODS

=head2 bind

Bind the connection, authenticating via SASL if we are configured to
do so.

    $conn->bind(
        host => 'ldap.ufl.edu',
        krb5 => {
            principal  => 'user@ufl.edu',
            keytab     => '/home/user/keytab',
            lifetime   => 86400,  # 1 day
        },
        sasl => {
            service => 'user@ufl.edu',
        },
    );

=cut

sub bind {
    my ($self, %args) = @_;

    my %krb5_args = %{ delete $args{krb5} || {} };
    my %sasl_args = %{ delete $args{sasl} || {} };

    if (%krb5_args and %sasl_args) {
        $krb5_args{lifetime} ||= 3600;
        $krb5_args{command}  ||= '/usr/bin/kinit';

        $self->_krb5_login(%krb5_args);

        my $sasl = Authen::SASL->new(mechanism => 'GSSAPI', %sasl_args);
        $args{sasl} = $sasl;
    }

    return $self->next::method(%args);
}

=head2 _krb5_login

Request a Kerberos ticket.

    $self->_krb5_login(
        principal  => 'user@ufl.edu',
        keytab     => '/home/user/keytab',
        lifetime   => 86400,  # 1 day
    );

=cut

sub _krb5_login {
    my ($self, %args) = @_;

    # Set a different credential cache for the application
    my $cred_cache = $ENV{KRB5CCNAME} || "/tmp/krb5cc_$>_ufl_phonebook";
    $ENV{KRB5CCNAME} = $cred_cache;

    my $lifetime   = $args{lifetime};
    die 'You must specify the path to the credential cache' unless $cred_cache;

    my $mtime = (stat $cred_cache)[9];
    if (! $mtime or time() - $mtime > $lifetime / 2) {
        $self->_krb5_login_via_kinit(%args);
    }
}

=head2 _krb5_login_via_kinit

Request a Kerberos ticket using C<kinit>.

    $self->_krb5_login_via_kinit(
        principal  => 'user@ufl.edu',
        keytab     => '/home/user/keytab',
        lifetime   => 86400,  # 1 day
        command    => '/usr/local/bin/kinit',
    );

Note: You probably want to use L</_krb5_login> instead.

=cut

sub _krb5_login_via_kinit {
    my ($self, %args) = @_;

    my $principal  = $args{principal};
    my $keytab     = $args{keytab};
    my $lifetime   = $args{lifetime};
    my $command    = $args{command};

    die 'You must specify the principal' unless $principal;
    die 'No keytab found' unless $keytab and -f $keytab;
    die 'You must specify the lifetime' unless $lifetime;
    die 'No kinit command available' unless -x $command;

    my @cmd = ($command, '-l', $lifetime, '-k', '-t', $keytab, $principal);
    warn "Calling kinit: [" , join(' ', @cmd) . "]";
    eval {
        # Override the Catalyst::Engine::HTTP signal handler
        local $SIG{CHLD} = '';
        system(@cmd) == 0 or die("child exited with value " . ($? >> 8));
    };
    die "kinit failed: $@" if $@;
}

=head2 search

Request authorization and then search as the current L<Catalyst> user.

=cut

sub search {
    my $self = shift;
    my %args = scalar @_ == 1 ? (filter => shift) : @_;

    die 'No user found' unless $self->catalyst_user;

    my $auth = Net::LDAP::Control::ProxyAuth->new(
        authzID  => 'u:' . $self->catalyst_user->username,
        critical => 1,
    );

    push @{ $args{control} }, $auth;

    return $self->next::method(%args);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
