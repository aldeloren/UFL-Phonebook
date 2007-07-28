use strict;
use warnings;
use Test::More tests => 6;

use_ok('UFL::Phonebook::Unit');

my $DN = 'uflEduPsDeptId=02010601,ou=Organizations,dc=ufl,dc=edu';

my %attributes = (
    uflEduPsDeptId     => '02010601',
    uflEduUniversityId => 'UETHHG63',
);

my $entry = UFL::Phonebook::Unit->new($DN, %attributes);

isa_ok($entry, 'UFL::Phonebook::Unit');
is($entry->dn, $DN, 'dn matches');
is($entry->attributes, 2, 'has 3 attributes');
is($entry->uflEduPsDeptId, $attributes{uflEduPsDeptId}, 'uflEduPsDeptId matches');
is($entry->uflEduUniversityId, $attributes{uflEduUniversityId}, 'uflEduUniversityId matches');
