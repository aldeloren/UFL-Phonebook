use strict;
use warnings;
use File::Spec;
use FindBin;
use Test::MockObject;
use Test::More;

plan skip_all => 'set TEST_AUTHOR to enable this test' unless $ENV{TEST_AUTHOR};
plan tests    => 42;

use_ok('UFL::Phonebook::Model::Person');

my %config = (
    host        => 'misc01.osg.ufl.edu',
    base        => 'ou=People,dc=ufl,dc=edu',
    entry_class => 'UFL::Phonebook::Person',
);

# Mock Catalyst objects for authenticated tests
my $c = Test::MockObject->new;
$c->set_true('user_exists');

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

# Anonymous search for public person
{
    my $conn = $anonymous_model->ACCEPT_CONTEXT($c);
    my $mesg = $conn->search('uid=attest1');
    is($mesg->count, 1, 'anonymous search for public person returned something');

    my $entry = $mesg->entry(0);
    isa_ok($entry, 'UFL::Phonebook::Person');
    is($entry->uid, 'attest1', 'uid matches');
}

# Anonymous search for protected person
{
    my $conn = $anonymous_model->ACCEPT_CONTEXT($c);
    my $mesg = $conn->search('uid=dwc');
    is($mesg->count, 0, 'anonymous search for protected person returned nothing');
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
    $user->remove('id');
    $user->set_always('id', 'dwc');
    my $conn = $authenticated_model->ACCEPT_CONTEXT($c);

    my $mesg = $conn->search('uid=dwc');
    is($mesg->count, 1, 'authenticated search for protected person returned something');

    my $entry = $mesg->entry(0);
    isa_ok($entry, 'UFL::Phonebook::Person');
    is($entry->uid, 'dwc', 'uid matches');
    ok($entry->exists('uflEduGender'), 'has a uflEduGender');
    ok($entry->exists('uflEduUuid'), 'has a uflEduUuid');
}

# Faculty search for faculty
{
    $user->remove('id');
    $user->set_always('id', 'manuel81');
    my $conn = $authenticated_model->ACCEPT_CONTEXT($c);

    my $mesg = $conn->search('uid=tigrr');
    is($mesg->count, 1, 'faculty search for faculty returned something');

    my $entry = $mesg->entry(0);
    isa_ok($entry, 'UFL::Phonebook::Person');
    is($entry->uid, 'tigrr', 'uid matches');
    is($entry->eduPersonPrimaryAffiliation, 'faculty', 'primary affiliation is faculty');
    ok($entry->exists('postalAddress'), 'has a postal address');
    ok($entry->exists('telephoneNumber'), 'has a phone number');
    ok($entry->exists('mail'), 'entry has an email address');
}

# Faculty search for student
{
    $user->remove('id');
    $user->set_always('id', 'manuel81');
    my $conn = $authenticated_model->ACCEPT_CONTEXT($c);

    my $mesg = $conn->search('uid=shubha');
    is($mesg->count, 1, 'faculty search for student returned something');

    my $entry = $mesg->entry(0);
    isa_ok($entry, 'UFL::Phonebook::Person');
    is($entry->uid, 'shubha', 'uid matches');
    is($entry->eduPersonPrimaryAffiliation, 'student', 'primary affiliation is student');
    ok($entry->exists('postalAddress'), 'has a postal address');
    ok($entry->exists('telephoneNumber'), 'has a phone number');
    ok($entry->exists('mail'), 'entry has an email address');
}

# Student search for student
{
    $user->remove('id');
    $user->set_always('id', 'shubha');
    my $conn = $authenticated_model->ACCEPT_CONTEXT($c);

    my $mesg = $conn->search('uid=twishap');
    is($mesg->count, 1, 'student search for student returned something');

    my $entry = $mesg->entry(0);
    isa_ok($entry, 'UFL::Phonebook::Person');
    is($entry->uid, 'twishap', 'uid matches');
    is($entry->eduPersonPrimaryAffiliation, 'student', 'primary affiliation is student');
    ok($entry->exists('postalAddress'), 'has a postal address');
    ok($entry->exists('telephoneNumber'), 'has a phone number');
    ok(! $entry->exists('mail'), 'entry does not have an email address');
}

# Student search for student
{
    $user->remove('id');
    $user->set_always('id', 'twishap');
    my $conn = $authenticated_model->ACCEPT_CONTEXT($c);

    my $mesg = $conn->search('uid=shubha');
    is($mesg->count, 1, 'student search for student returned something');

    my $entry = $mesg->entry(0);
    isa_ok($entry, 'UFL::Phonebook::Person');
    is($entry->uid, 'shubha', 'uid matches');
    is($entry->eduPersonPrimaryAffiliation, 'student', 'primary affiliation is student');
    ok($entry->exists('postalAddress'), 'has a postal address');
    ok($entry->exists('telephoneNumber'), 'has a phone number');
    ok(! $entry->exists('mail'), 'entry does not have an email address');
}
