package UFL::Phonebook::LDAP::Connection;

use strict;
use warnings;
use base qw/Catalyst::Model::LDAP::Connection/;
use Authen::SASL qw/Perl/;
use Carp qw/croak/;
use Class::C3;
use IPC::Open3 qw//;
use Net::LDAP::Control::ProxyAuth;

__PACKAGE__->mk_accessors(qw/catalyst_user/);

=head1 NAME

UFL::Phonebook::LDAP::Connection - LDAP connection for authenticated requests

=head1 DESCRIPTION

Overrides L<Catalyst::Model::LDAP::Connection> to assume the identity
of the person associated with the current L<Catalyst> user.

=head1 METHODS

=head2 bind

Bind the connection, authenticating via SASL.

    $conn->bind(
        host => 'ldap.ufl.edu',
        krb5 => {
            principal => 'user@ufl.edu',
            keytab    => '/home/user/keytab',
            lifetime  => 86400,  # 1 day
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

    my $catalyst_user = delete $args{catalyst_user};

    if (%krb5_args and %sasl_args and $catalyst_user) {
        # Store the Catalyst user for use in search
        $self->catalyst_user($catalyst_user);

        $self->_krb5_login(%krb5_args);

        my $sasl = Authen::SASL->new(mechanism => 'GSSAPI', %sasl_args);
        $args{sasl} = $sasl;
    }

    $self->next::method(%args);
}

=head2 _krb5_login

Request a Kerberos ticket.

    $self->_krb5_login(
        principal => 'user@ufl.edu',
        keytab    => '/home/user/keytab',
        lifetime  => 86400,  # 1 day
    );

=cut

sub _krb5_login {
    my ($self, %args) = @_;

    my $keytab   = $args{keytab};
    my $lifetime = $args{lifetime} || 3600;

    die 'No keytab found' unless $keytab and -f $keytab;

    my $kinited_file = "$keytab.$>.kinited";
    my $mtime = (stat $kinited_file)[9];

    if (! $mtime or time() - $mtime > $lifetime / 2) {
        $self->_krb5_login_via_kinit(%args);

        open my $fh, '>', $kinited_file
            or die "Error storing kinit time: $!";
        close $fh;
    }
}

=head2 _krb5_login_via_kinit

Request a Kerberos ticket using C<kinit>.

    $self->_krb5_login(
        principal => 'user@ufl.edu',
        keytab    => '/home/user/keytab',
        lifetime  => 86400,  # 1 day
        command   => '/usr/local/bin/kinit',
        timeout   => 10,  # Wait 10 seconds for kinit to finish
    );

Note: You probably want to use L</_krb5_login> instead.

=cut

sub _krb5_login_via_kinit {
    my ($self, %args) = @_;

    my $principal = $args{principal};
    my $keytab    = $args{keytab};
    my $lifetime  = $args{lifetime} || 3600;
    my $command   = $args{command} || '/usr/bin/kinit';
    my $timeout   = $args{timeout} || 10;

    die 'No principal found' unless $principal;
    die 'No keytab found' unless $keytab and -f $keytab;
    die 'No kinit command available' unless -x $command;

    my @cmd = ($command, '-l', $lifetime, '-k', '-t', $keytab, $principal);
    my ($in, $out, $err);
    eval {
        local $SIG{ALRM} = sub { die "timeout after $timeout seconds" };
        alarm $timeout;
        my $pid = IPC::Open3::open3($in, $out, $err, @cmd);
        waitpid $pid, 0;
        alarm 0;
    };
    die "kinit failed: $@" if $@;
}

=head2 search

Request authorization and then search as the current L<Catalyst> user.

=cut

sub search {
    my $self = shift;
    my %args = scalar @_ == 1 ? (filter => shift) : @_;

    if ($self->catalyst_user) {
        my $auth = Net::LDAP::Control::ProxyAuth->new(
            authzID => 'u:' . $self->catalyst_user->id,
        );

        push @{ $args{control} }, $auth;
    }

    $self->next::method(%args);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
