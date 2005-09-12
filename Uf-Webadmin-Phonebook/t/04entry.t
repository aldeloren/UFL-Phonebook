use strict;
use Test::More tests => 5;
use Uf::Webadmin::Phonebook::M::People;
use Data::Dumper;

use_ok('Uf::Webadmin::Phonebook::Entry');

my $uid = 'gkt';

my $results = Uf::Webadmin::Phonebook::M::People->search("(uid=$uid)");
ok(scalar @{ $results } > 0, 'got results');

my @entries = map { Uf::Webadmin::Phonebook::Entry->new($_) } @{ $results };
my $entry = $entries[0];
ok(scalar($entry->attributes) > 0, 'has attributes');
ok($entry->uid eq $uid, 'uid matches');
ok(scalar($entry->uflEduAllPhones) > 0, 'has at least one phone number');
