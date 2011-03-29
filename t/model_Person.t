#!perl

use strict;
use warnings;
use File::Spec;
use FindBin;
use Test::MockObject;
use Test::More;

plan skip_all => 'set TEST_LDAP to enable this test' unless $ENV{TEST_LDAP};
plan tests    => 1 + 3*2 + 14*26 + 4*1;

use_ok('UFL::Phonebook::Model::Person');


my %config = (
    host        => $ENV{TEST_LDAP_HOST} || 'ldap.ufl.edu',
    base        => 'ou=People,dc=ufl,dc=edu',
    entry_class => 'UFL::Phonebook::Person',
);

unless ($ENV{TEST_LDAP_NO_TLS}) {
    $config{start_tls} = 1;
    $config{start_tls_options} = {
        verify => 'require',
        capath => '/etc/ssl/certs'
    };
}

# Mock Catalyst objects for authenticated tests
my $c = Test::MockObject->new;

my $user = Test::MockObject->new;
$c->mock('user', sub { $user });


#
# Anonymous searches
#

my $anonymous_model = UFL::Phonebook::Model::Person->new({
    %config,
});

isa_ok($anonymous_model, 'UFL::Phonebook::Model::Person');
isa_ok($anonymous_model, 'Catalyst::Model::LDAP');

# Anonymous search for protected person
TODO: {
    todo_skip('Need to find another protected person', 1);
    my $mesg = search($anonymous_model, undef, 'dwc', 0);
}

# Anonymous search for staff
{
    my $mesg = search($anonymous_model, undef, 'asr', 1, 1, 0, 0, 0, 'staff');
}

# Anonymous search for student
{
    my $mesg = search($anonymous_model, undef, 'shubha', 0);
}

# Anonymous search for member
{
    my $mesg = search($anonymous_model, undef, 'linkatri', 1, 0, 0, 0, 0, 'member');
}


#
# Authenticated searches
#

SKIP: {
    skip 'set TEST_LDAP_PRINCIPAL to test SASL access', 2 + 8*26 + 2*1
        unless $ENV{TEST_LDAP_PRINCIPAL};

    $ENV{KRB5CCNAME} = "/tmp/krb5cc_$>_ufl_phonebook_tests";

    my $principal = $ENV{TEST_LDAP_PRINCIPAL};
    (my $filename = $principal) =~ s|/|_|g;
    my $keytab = File::Spec->join($FindBin::Bin, File::Spec->updir, 'keytab', $filename);
    my $authenticated_model = UFL::Phonebook::Model::Person->new({
        %config,
        connection_class => 'UFL::Phonebook::LDAP::Connection',
        krb5 => {
            principal => $principal,
            keytab    => $keytab,
        },
        sasl => {
            service => $principal,
        },
    });

    isa_ok($authenticated_model, 'UFL::Phonebook::Model::Person');
    isa_ok($authenticated_model, 'Catalyst::Model::LDAP');

    # Protected person search for self
    TODO: {
        todo_skip('Need to find another protected person', 26);
        my $mesg = search($authenticated_model, 'dwc', 'dwc', 1, 1, 1, 1, 1, 'staff');
    }

    # Faculty search for faculty
    {
        my $mesg = search($authenticated_model, 'manuel81', 'tigrr', 1, 1, 0, 0, 0, 'faculty');
    }

    # Faculty search for faculty
    {
        my $mesg = search($authenticated_model, 'tigrr', 'manuel81', 1, 1, 0, 0, 0, 'faculty');
    }

    # Faculty search for student
    {
        my $mesg = search($authenticated_model, 'manuel81', 'egoldsmith', 1, 1, 0, 0, 0, 'student');
    }

    # Student search for student
    {
        my $mesg = search($authenticated_model, 'egoldsmith', 'lesleebh08', 1, 1, 0, 0, 0, 'student');
    }

    # Student search for student
    {
        my $mesg = search($authenticated_model, 'lesleebh08', 'egoldsmith', 1, 1, 0, 0, 0, 'student');
    }

    # Staff search for student
    {
        my $mesg = search($authenticated_model, 'dwc', 'egoldsmith', 1, 1, 0, 0, 0, 'student');
    }

    # Staff search for member
    {
        my $mesg = search($authenticated_model, 'dwc', 'linkatri', 1, 0, 0, 0, 0, 'member');
    }

    # Staff search for protected person
    TODO: {
        todo_skip('Need to find another protected person', 1);
        my $mesg = search($authenticated_model, 'asr', 'dwc', 0);
    }

    # Search for student with SASL but without proxy authentication
    {
        eval { search($authenticated_model, undef, 'egoldsmith', 1, 1, 0, 0, 0, 'student') };

        my $error = $@;
        ok($error, "search for student with SASL but without proxy authentication died ($error)");
    }
}


#
# Adminstrative ID access
#

SKIP: {
    skip 'set TEST_LDAP_BINDDN and TEST_LDAP_PASSWORD to test administrative ID access', 2 + 4*26
        unless $ENV{TEST_LDAP_BINDDN} and $ENV{TEST_LDAP_PASSWORD};

    my $admin_model = UFL::Phonebook::Model::Person->new({
        %config,
        dn       => $ENV{TEST_LDAP_BINDDN},
        password => $ENV{TEST_LDAP_PASSWORD},
    });

    isa_ok($admin_model, 'UFL::Phonebook::Model::Person');
    isa_ok($admin_model, 'Catalyst::Model::LDAP');

    # Search for protected person
    TODO: {
        todo_skip('Need to find another protected person', 26);
        my $mesg = search($admin_model, $ENV{TEST_LDAP_BINDDN}, 'dwc', 1, 1, 1, 1, 1, 'staff');
    }

    # Search for faculty
    {
        my $mesg = search($admin_model, $ENV{TEST_LDAP_BINDDN}, 'tigrr', 1, 1, 1, 1, 1, 'faculty');
    }

    # Search for faculty
    {
        my $mesg = search($admin_model, $ENV{TEST_LDAP_BINDDN}, 'asr', 1, 1, 1, 1, 1, 'staff');
    }

    # Search for student
    {
        my $mesg = search($admin_model, $ENV{TEST_LDAP_BINDDN}, 'egoldsmith', 1, 1, 1, 1, 1, 'student');
    }
}


# Total: 26 tests
sub search {
    my ($model, $requestor, $target, $expected_count, $has_phone, $has_home_phone, $has_home_address, $has_personal, $affiliation) = @_;

    if ($requestor) {
        diag("$requestor searching for $target");
        $user->set_always('ldap_username', $requestor);
        $c->set_true('user_exists');
    }
    else {
        diag("Anonymous search for $target");
        $c->set_false('user_exists');
    }

    my $conn = $model->ACCEPT_CONTEXT($c);

    my $mesg = $conn->search("uid=$target");
    my $count = $mesg->count;
    is($count, $expected_count, "Found $expected_count result" . ($expected_count == 1 ? '' : 's'));

    if ($expected_count > 0) {
        check_entry($mesg->shift_entry, $target, $has_phone, $has_home_phone, $has_home_address, $has_personal, $affiliation);
    }

    $user->remove('ldap_username');

    return $mesg;
}

# Total: 25 tests
sub check_entry {
    my ($entry, $uid, $has_phone, $has_home_phone, $has_home_address, $has_personal, $affiliation) = @_;

    SKIP: {
        skip 'need an entry to run tests on it', 25 unless $entry;

        diag($entry->uid . ': ' . join(', ', $entry->attributes));

        isa_ok($entry, 'UFL::Phonebook::Person');

        ok($entry->dn, "LDAP infrastructure fields: '$uid' has a DN");
        ok($entry->exists('objectClass'), "LDAP infrastructure fields: '$uid' has at least one object class");
        ok($entry->exists('ou'), "LDAP infrastructure fields: '$uid' has an organizational unit");

        ok($entry->exists('uflEduUniversityId'), "administrative fields: '$uid' has a UFID");
        ok($entry->exists('uflEduPsDeptId'), "administrative fields: '$uid' has a PeopleSoft department ID");
        ok($entry->exists('eduPersonOrgDN'), "administrative fields: '$uid' has an eduPerson organization DN");
        ok($entry->exists('departmentNumber'), "administrative fields: '$uid' has a department number");
        ok($entry->exists('uflEduPrivacy'), "administrative fields: '$uid' has privacy information");

        ok($entry->exists('displayName'), "basic person identification fields: '$uid' has a display name");
        ok($entry->exists('cn'), "basic person identification fields: '$uid' has a common name");
        ok($entry->exists('sn'), "basic person identification fields: '$uid' has a surname");
        ok($entry->exists('givenName'), "basic person identification fields: '$uid' has a given name");
        is($entry->eduPersonPrimaryAffiliation, $affiliation, "basic person identification fields: '$uid' has a primary affiliation of '$affiliation'");

        ok($entry->exists('telephoneNumber') == $has_phone, "primary contact information fields: '$uid' has an official university phone number");
        ok($entry->exists('street'), "primary contact information fields: '$uid' has an official university street address");
        ok($entry->exists('postalAddress'), "primary contact information fields: '$uid' has an official university postal address");
        ok($entry->exists('registeredAddress'), "primary contact information fields: '$uid' has an official university registered address");
        ok($entry->exists('uflEduOfficeLocation'), "primary contact information fields: '$uid' has an official university office location");

        ok($entry->exists('homePhone') == $has_home_phone, "home contact information fields: '$uid' " . ($has_home_phone ? 'has' : 'does not have') . " a home phone number");
        ok($entry->exists('homePostalAddress') == $has_home_address, "home contact information fields: '$uid' " . ($has_home_address ? 'has' : 'does not have') . " a home postal address");

        ok($entry->exists('mail'), "primary email fields: '$uid' has a primary email address");

        is($entry->uid, $uid, "POSIX account fields: '$uid' has correct uid");

        ok($entry->exists('uflEduBirthDate') == $has_personal, "personal information fields: '$uid' " . ($has_personal ? 'has' : 'does not have') . " a birth date");
        ok($entry->exists('uflEduGender') == $has_personal, "personal information fields: '$uid' " . ($has_personal ? 'has' : 'does not have') . " a gender");
    }
}
