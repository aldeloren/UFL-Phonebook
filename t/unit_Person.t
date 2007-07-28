use strict;
use warnings;
use Test::More tests => 15;
use UFL::Phonebook;

use_ok('UFL::Phonebook::Person');

my $DN                 = 'uflEduUniversityId=FAKE,ou=People,dc=ufl,dc=edu';
my $TITLE              = 'FAKE';
my $STREET             = '700 FAKE RD';
my $LOCALITY           = 'FAKE';
my $REGION             = 'FL';
my $DOMINION           = 'US';
my $POSTAL_CODE        = '326112065';
my $PARSED_POSTAL_CODE = '32611-2065';
my $ADDRESS            = join('$', $TITLE, $STREET, "$LOCALITY, $REGION, $DOMINION", " $POSTAL_CODE");

my %attributes = (
    uid => 'test',
    uflEduAllPostalAddresses => [
        q[UF Business Physical Location Address$FAKE$700 FAKE RD$FAKE, FL, US$ 326112065],
        q[UF Business Mailing Address$PO BOX 112065$GAINESVILLE, FL, US$ 326112065],
    ],
    uflEduAllPhones => [
        q[Local Home Telephone Number:+1 352 3923753],
        q[Facsimile Telephone Number:+1 392 3753],
    ],
);

my $entry = UFL::Phonebook::Person->new($DN, %attributes);

isa_ok($entry, 'UFL::Phonebook::Person');
is($entry->dn, $DN, 'dn matches');
is($entry->attributes, 3, 'has 3 attributes');
is($entry->uid, $attributes{uid}, 'uid matches');

my @phones = $entry->uflEduAllPhones;
is(@phones, 2, 'has 4 phone numbers');

isa_ok($entry->uflEduAllPostalAddresses, 'UFL::Phonebook::Entry::PostalAddressCollection');
isa_ok($entry->uflEduAllPostalAddresses->campus, 'UFL::Phonebook::Entry::PostalAddress');
my $campus_address = $entry->uflEduAllPostalAddresses->campus;
is($campus_address->title, $TITLE, 'title matches');
is($campus_address->street, $STREET, 'street matches');
is($campus_address->locality, $LOCALITY, 'locality matches');
is($campus_address->region, $REGION, 'region matches');
is($campus_address->dominion, $DOMINION, 'dominion matches');
is($campus_address->postal_code, $PARSED_POSTAL_CODE, 'postal code matches');
is($campus_address->as_string, $ADDRESS, 'campus address matches');
