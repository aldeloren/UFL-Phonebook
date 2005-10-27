use strict;
use warnings;
use Test::More tests => 6;
use Uf::Webadmin::Phonebook;

use_ok('Uf::Webadmin::Phonebook::Entry');

my $UID = 'gkt';

my $people  = Uf::Webadmin::Phonebook->comp('M::People');
my $results = $people->search("(uid=$UID)");
ok(scalar @{ $results } > 0, 'got results');

my @entries = map { Uf::Webadmin::Phonebook::Entry->new($_) } @{ $results };

my $entry = $entries[0];

ok(scalar($entry->attributes) > 0, 'has attributes');
ok($entry->uid eq $UID, 'uid');
ok(scalar($entry->uflEduAllPhones) > 0, 'has a phone number');

ok($entry->get_postal_address('campus') eq "CREC - LAKE ALFRED
700 EXPERIMENT STATION RD
LAKE ALFRED, FL, US
33850-2243", 'campus address');
