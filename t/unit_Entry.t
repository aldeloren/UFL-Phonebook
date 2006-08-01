use strict;
use warnings;
use Test::More tests => 12;
use Phonebook;

use_ok('Phonebook::Entry');

my $UID                = 'gkt';
my $TITLE              = 'CREC - LAKE ALFRED';
my $STREET             = '700 EXPERIMENT STATION RD';
my $LOCALITY           = 'LAKE ALFRED';
my $REGION             = 'FL';
my $DOMINION           = 'US';
my $POSTAL_CODE        = '338502243';
my $PARSED_POSTAL_CODE = '33850-2243';
my $ADDRESS            = join '$', $TITLE, $STREET, "$LOCALITY, $REGION, $DOMINION", " $POSTAL_CODE";

my $mesg    = Phonebook->model('Person')->search("(uid=$UID)");
my @entries = $mesg->entries;
cmp_ok(scalar @entries, '>', 0, 'got results');

my $entry = Phonebook::Entry->new($entries[0]);

cmp_ok(scalar @{ $entry->attributes }, '>', 0, 'has attributes');
is($entry->uid, $UID, 'uid');
cmp_ok(scalar $entry->uflEduAllPhones, '>', 0, 'has a phone number');

my $campus_address = $entry->uflEduAllPostalAddresses->campus;
is($campus_address->title, $TITLE, 'title');
is($campus_address->street, $STREET, 'street');
is($campus_address->locality, $LOCALITY, 'locality');
is($campus_address->region, $REGION, 'region');
is($campus_address->dominion, $DOMINION, 'dominion');
is($campus_address->postal_code, $PARSED_POSTAL_CODE, 'postal code');
is($campus_address->as_string, $ADDRESS, 'campus address');
