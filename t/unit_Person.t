use strict;
use warnings;
use Test::More tests => 24;

use_ok('UFL::Phonebook::Person');

my $DN                 = 'uflEduUniversityId=FAKE,ou=People,dc=ufl,dc=edu';
my $UID                = 'test';
my $TELEPHONE_NUMBER   = '+1 352 3923753';
my $TITLE              = 'FAKE';
my $STREET             = '700 FAKE RD';
my $LOCALITY           = 'FAKE';
my $REGION             = 'FL';
my $DOMINION           = 'US';
my $POSTAL_CODE        = '326112065';
my $PARSED_POSTAL_CODE = '32611-2065';
my $ADDRESS            = join('$', $TITLE, $STREET, "$LOCALITY, $REGION, $DOMINION", " $POSTAL_CODE");

my %attributes = (
    uid             => $UID,
    telephoneNumber => $TELEPHONE_NUMBER,
    postalAddress   => $ADDRESS,
    uflEduAllPostalAddresses => [
        'UF Business Physical Location Address$' . $ADDRESS,
    ],
    uflEduAllPhones => [
        'Local Home Telephone Number:' . $TELEPHONE_NUMBER,
    ],
);

my $entry = UFL::Phonebook::Person->new($DN, %attributes);

isa_ok($entry, 'UFL::Phonebook::Person');
is($entry->dn, $DN, 'dn matches');
is($entry->attributes, 5, 'has the correct number of attributes');
is($entry->uid, $UID, 'uid matches');
is($entry->telephoneNumber, $TELEPHONE_NUMBER, 'telephoneNumber matches');

isa_ok($entry->postalAddress, 'UFL::Phonebook::PostalAddress');
is($entry->postalAddress->title, $TITLE, 'title matches');
is($entry->postalAddress->street, $STREET, 'street matches');
is($entry->postalAddress->locality, $LOCALITY, 'locality matches');
is($entry->postalAddress->region, $REGION, 'region matches');
is($entry->postalAddress->dominion, $DOMINION, 'dominion matches');
is($entry->postalAddress->postal_code, $PARSED_POSTAL_CODE, 'postal code matches');
is($entry->postalAddress->as_string, $ADDRESS, 'postal address matches');

my @phones = $entry->uflEduAllPhones;
is(@phones, 1, 'has a phone number from uflEduAllPhones');

isa_ok($entry->uflEduAllPostalAddresses, 'UFL::Phonebook::PostalAddressCollection');
isa_ok($entry->uflEduAllPostalAddresses->campus, 'UFL::Phonebook::PostalAddress');
my $campus_address = $entry->uflEduAllPostalAddresses->campus;
is($campus_address->title, $TITLE, 'title matches');
is($campus_address->street, $STREET, 'street matches');
is($campus_address->locality, $LOCALITY, 'locality matches');
is($campus_address->region, $REGION, 'region matches');
is($campus_address->dominion, $DOMINION, 'dominion matches');
is($campus_address->postal_code, $PARSED_POSTAL_CODE, 'postal code matches');
is($campus_address->as_string, $ADDRESS, 'campus address matches');
