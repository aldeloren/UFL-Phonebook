use strict;
use warnings;
use File::Spec;
use FindBin;
use Test::MockObject;
use Test::More;

plan skip_all => 'set TEST_AUTHOR to enable this test' unless $ENV{TEST_AUTHOR};
plan tests    => 6 + 8*24;

use_ok('UFL::Phonebook::Model::Person');

my %config = (
    host        => 'misc01.osg.ufl.edu',
    base        => 'ou=People,dc=ufl,dc=edu',
    entry_class => 'UFL::Phonebook::Person',
);

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
{
    my $mesg = search($anonymous_model, 'uid=dwc');
    is($mesg->count, 0, 'anonymous search for protected person returned nothing');
}

# Anonymous search for staff
{
    my $mesg = search($anonymous_model, 'uid=asr');
    is($mesg->count, 1, 'anonymous search for staff returned something');

    check_entry($mesg->entry(0), 'asr', 1, 1, 1, 0, 'staff');
}

# Anonymous search for student
{
    my $mesg = search($anonymous_model, 'uid=shubha');
    is($mesg->count, 1, 'anonymous search for a student returned something');

    check_entry($mesg->entry(0), 'shubha', 1, 1, 0, 0, 'student');
}


#
# Authenticated searches
#

my $principal = '02010600/app/phonebook';
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
{
    $user->set_always('id', 'dwc');
    $c->set_true('user_exists');

    my $mesg = search($authenticated_model, 'uid=dwc');
    is($mesg->count, 1, 'authenticated search for protected person returned something');

    check_entry($mesg->entry(0), 'dwc', 1, 1, 1, 1, 'staff');

    $user->remove('id');
}

# Faculty search for faculty
{
    $user->set_always('id', 'manuel81');
    $c->set_true('user_exists');

    my $mesg = search($authenticated_model, 'uid=tigrr');
    is($mesg->count, 1, 'faculty search for faculty returned something');

    check_entry($mesg->entry(0), 'tigrr', 1, 1, 1, 0, 'faculty');

    $user->remove('id');
}

# Faculty search for student
{
    $user->set_always('id', 'manuel81');
    $c->set_true('user_exists');

    my $mesg = search($authenticated_model, 'uid=shubha');
    is($mesg->count, 1, 'faculty search for a student returned something');

    check_entry($mesg->entry(0), 'shubha', 1, 1, 1, 0, 'student');

    $user->remove('id');
}

# Student search for student
{
    $user->set_always('id', 'shubha');
    $c->set_true('user_exists');

    my $mesg = search($authenticated_model, 'uid=twishap');
    is($mesg->count, 1, 'student search for a student returned something');

    check_entry($mesg->entry(0), 'twishap', 0, 0, 0, 0, 'student');

    $user->remove('id');
}

# Student search for student
{
    $user->set_always('id', 'twishap');
    $c->set_true('user_exists');

    my $mesg = search($authenticated_model, 'uid=shubha');
    is($mesg->count, 1, 'student search for a student returned something');

    check_entry($mesg->entry(0), 'shubha', 1, 1, 0, 0, 'student');

    $user->remove('id');
}


# Search for student with SASL but without proxy authentication
{
    $c->set_false('user_exists');

    my $mesg = search($authenticated_model, 'uid=shubha');
    is($mesg->count, 1, 'search for a student without proxy authentication returned something');

    check_entry($mesg->entry(0), 'shubha', 1, 1, 0, 0, 'student');
}


sub search {
    my ($model, $filter) = @_;

    my $conn = $model->ACCEPT_CONTEXT($c);

    return $conn->search($filter);
}

sub check_entry {
    my ($entry, $uid, $has_phone, $has_office, $has_mail, $has_personal, $affiliation) = @_;

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

    ok($entry->exists('telephoneNumber') == $has_phone, "primary contact information fields: '$uid' " . ($has_phone ? 'has' : 'does not have') . " an official university phone number");
    ok($entry->exists('street'), "primary contact information fields: '$uid' has an official university street address");
    ok($entry->exists('postalAddress'), "primary contact information fields: '$uid' has an official university postal address");
    ok($entry->exists('registeredAddress'), "primary contact information fields: '$uid' has an official university registered address");
    ok($entry->exists('uflEduOfficeLocation') == $has_office, "primary contact information fields: '$uid' " . ($has_office ? 'has' : 'does not have') . " an official university office location");

    ok($entry->exists('mail') == $has_mail, "primary email fields: '$uid' " . ($has_mail ? 'has' : 'does not have') . " a primary email address");

    is($entry->uid, $uid, "POSIX account fields: '$uid' has correct uid");

    ok($entry->exists('uflEduBirthDate') == $has_personal, "personal information fields: '$uid' " . ($has_personal ? 'has' : 'does not have') . " a birth date");
    ok($entry->exists('uflEduGender') == $has_personal, "personal information fields: '$uid' " . ($has_personal ? 'has' : 'does not have') . " a gender");
}
