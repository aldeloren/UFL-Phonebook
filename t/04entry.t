use strict;
use warnings;
use Test::More tests => 12;
use Uf::Webadmin::Phonebook;

use_ok('Uf::Webadmin::Phonebook::Entry');

my $UID                = 'gkt';
my $TITLE              = 'CREC - LAKE ALFRED';
my $STREET             = '700 EXPERIMENT STATION RD';
my $LOCALITY           = 'LAKE ALFRED';
my $REGION             = 'FL';
my $DOMINION           = 'US';
my $POSTAL_CODE        = '338502243';
my $PARSED_POSTAL_CODE = '33850-2243';
my $ADDRESS            = join '$', $TITLE, $STREET, "$LOCALITY, $REGION, $DOMINION", " $POSTAL_CODE";

my $people  = Uf::Webadmin::Phonebook->comp('Model::People');
my $results = $people->search("(uid=$UID)");
cmp_ok(scalar @{ $results }, '>', 0, 'got results');

my @entries = map { Uf::Webadmin::Phonebook::Entry->new($_) } @{ $results };

my $entry = $entries[0];

cmp_ok(scalar @{ $entry->attribute }, '>', 0, 'has attributes');
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
