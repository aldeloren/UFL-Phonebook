use strict;
use warnings;
use Test::More tests => 6;

use_ok('UFL::Phonebook::Entry');

my $DN = 'uflEduUniversityId=FAKE,ou=People,dc=ufl,dc=edu';

my %attributes = (
    uid        => 'test',
    loginShell => '/usr/local/bin/glshell',
);

my $entry = UFL::Phonebook::Entry->new($DN, %attributes);

isa_ok($entry, 'UFL::Phonebook::Entry');
is($entry->dn, $DN, 'dn matches');
is($entry->attributes, 2, 'has 3 attributes');
is($entry->uid, $attributes{uid}, 'uid matches');
is($entry->loginShell, $attributes{loginShell}, 'loginShell matches');
