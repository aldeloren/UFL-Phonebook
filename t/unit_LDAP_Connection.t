use strict;
use warnings;
use FindBin;
use Test::More;

plan skip_all => 'set TEST_LDAP to enable this test' unless $ENV{TEST_LDAP};
plan tests    => 13;

use_ok('UFL::Phonebook::LDAP::Connection');


my %config = (
    host => $ENV{TEST_LDAP_HOST} || 'ldap.ufl.edu',
    base => 'ou=People,dc=ufl,dc=edu',
);

# Anonymous bind
{
    diag("Doing anonymous bind against $config{host}");

    my $conn = UFL::Phonebook::LDAP::Connection->new(%config);
    isa_ok($conn, 'UFL::Phonebook::LDAP::Connection');
    isa_ok($conn, 'Catalyst::Model::LDAP::Connection');
    isa_ok($conn, 'Net::LDAP');

    my $mesg = $conn->bind;

    ok(! $mesg->is_error, 'Anonymous bind completed successfully');
}

# Simple bind
SKIP: {
    skip 'set TEST_LDAP_BINDDN and TEST_LDAP_PASSWORD to test a simple bind', 4
        unless $ENV{TEST_LDAP_BINDDN} and $ENV{TEST_LDAP_PASSWORD};

    diag("Doing simple bind against $config{host}");

    my $conn = UFL::Phonebook::LDAP::Connection->new(%config);
    isa_ok($conn, 'UFL::Phonebook::LDAP::Connection');
    isa_ok($conn, 'Catalyst::Model::LDAP::Connection');
    isa_ok($conn, 'Net::LDAP');

    my $mesg = $conn->bind(
        dn       => $ENV{TEST_LDAP_BINDDN},
        password => $ENV{TEST_LDAP_PASSWORD},
    );

    ok(! $mesg->is_error, 'Simple bind completed successfully');
}

# SASL bind
SKIP: {
    skip 'set TEST_LDAP_PRINCIPAL to test a SASL bind', 4
        unless $ENV{TEST_LDAP_PRINCIPAL};

    $ENV{KRB5CCNAME} = "/tmp/krb5cc_$>_ufl_phonebook_tests";

    my $principal = $ENV{TEST_LDAP_PRINCIPAL};
    (my $filename = $principal) =~ s|/|_|g;
    my $keytab = File::Spec->join($FindBin::Bin, File::Spec->updir, 'keytab', $filename);

    diag("Doing SASL bind against $config{host}");

    my $conn = UFL::Phonebook::LDAP::Connection->new(%config);
    isa_ok($conn, 'UFL::Phonebook::LDAP::Connection');
    isa_ok($conn, 'Catalyst::Model::LDAP::Connection');
    isa_ok($conn, 'Net::LDAP');

    my $mesg = $conn->bind(
        krb5 => {
            principal => $principal,
            keytab    => $keytab,
        },
        sasl => {
            service => $principal,
        },
    );

    ok(! $mesg->is_error, 'SASL bind completed successfully');
}
