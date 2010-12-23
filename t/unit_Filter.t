use strict;
use warnings;
use Test::More tests => 13;

use_ok('UFL::Phonebook::Filter::Abstract');

my $filter = UFL::Phonebook::Filter::Abstract->new;
$filter->add(qw/objectClass = person/);

my $simple = '(objectClass=person)';
is($filter->as_string, $simple, 'simple filter');
is($filter, $simple, 'simple filter with auto-stringify');

my $filter2 = UFL::Phonebook::Filter::Abstract->new('!')->add(qw/telephoneNumber = */);

my $logical_not = '(!(telephoneNumber=*))';
is($filter2->as_string, $logical_not, 'logical NOT filter');
is($filter2, $logical_not, 'logical NOT filter with auto-stringify');

$filter->add($filter2);

my $logical_and = '(&(objectClass=person)(!(telephoneNumber=*)))';
is($filter->as_string, $logical_and, 'logical AND of two filters');
is($filter, $logical_and, 'logical AND of two filters with auto-stringify');

my $filter3 = UFL::Phonebook::Filter::Abstract->new('|');
$filter3->add(qw/cn = *a*b*/);
$filter3->add(qw/cn = *b*a*/);

my $logical_or = '(|(cn=*a*b*)(cn=*b*a*))';
is($filter3->as_string, $logical_or, 'logical OR');
is($filter3, $logical_or, 'logical OR with auto-stringify');

$filter->add($filter3);

my $complex = '(&(objectClass=person)(!(telephoneNumber=*))(|(cn=*a*b*)(cn=*b*a*)))';
is($filter->as_string, $complex, 'complex filter');
is($filter, $complex, 'complex filter with auto-stringify');

# Test object string equality via overload
my $obj_eq1 = UFL::Phonebook::Filter::Abstract->new('|');
$obj_eq1->add(qw/objectClass = person/);

my $obj_eq2 = UFL::Phonebook::Filter::Abstract->new('|');
$obj_eq2->add(qw/objectClass = person/);

is($obj_eq1, $obj_eq2, 'string equality via overload');

$obj_eq2->add(qw/cn = Smith/);
isnt($obj_eq1, $obj_eq2, 'string inequality via overload');
