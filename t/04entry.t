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

my $people  = Uf::Webadmin::Phonebook->comp('M::People');
my $results = $people->search("(uid=$UID)");
ok(scalar @{ $results } > 0, 'got results');

my @entries = map { Uf::Webadmin::Phonebook::Entry->new($_) } @{ $results };

my $entry = $entries[0];

ok(scalar(@{ $entry->attribute } > 0), 'has attributes');
ok($entry->uid eq $UID, 'uid');
ok(scalar($entry->uflEduAllPhones) > 0, 'has a phone number');

my $campus_address = $entry->uflEduAllPostalAddresses->campus;
ok($campus_address->title eq $TITLE, 'title');
ok($campus_address->street eq $STREET, 'street');
ok($campus_address->locality eq $LOCALITY, 'locality');
ok($campus_address->region eq $REGION, 'region');
ok($campus_address->dominion eq $DOMINION, 'dominion');
ok($campus_address->postal_code eq $PARSED_POSTAL_CODE, 'postal code');
ok($campus_address->as_string eq $ADDRESS, 'campus address');
