use strict;
use Test::More tests => 4;
use Uf::Webadmin::Phonebook::M::People;
use Data::Dumper;

use_ok('Uf::Webadmin::Phonebook::Entry');

my $uid = 'gkt';

my $results = Uf::Webadmin::Phonebook::M::People->search("(uid=$uid)");
ok(scalar @{ $results } > 0, 'got results');

my @entries = map { Uf::Webadmin::Phonebook::Entry->new($_) } @{ $results };
ok(scalar($entries[0]->attributes) > 0, 'has attributes');
ok($entries[0]->{uid} eq $uid, 'uid matches');
