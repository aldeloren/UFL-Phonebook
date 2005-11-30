use strict;
use warnings;
use Test::More tests => 9;

use_ok('Uf::Webadmin::Phonebook::Filter::Abstract');

my $filter = Uf::Webadmin::Phonebook::Filter::Abstract->new;
ok($filter);
$filter->add(qw/objectClass = person/);
is($filter->as_string, '(objectClass=person)', 'simple filter');

my $filter2 = Uf::Webadmin::Phonebook::Filter::Abstract->new('!')->add(qw/telephoneNumber = */);
ok($filter2);
is($filter2->as_string, '(!(telephoneNumber=*))', 'logical NOT filter');

$filter->add($filter2);
is($filter->as_string, '(&(objectClass=person)(!(telephoneNumber=*)))', 'logical AND of two filters');

my $filter3 = Uf::Webadmin::Phonebook::Filter::Abstract->new('|');
ok($filter3);
$filter3->add(qw/cn = *a*b*/);
$filter3->add(qw/cn = *b*a*/);
is($filter3->as_string, '(|(cn=*a*b*)(cn=*b*a*))', 'logical OR');

$filter->add($filter3);
is($filter->as_string, '(&(objectClass=person)(!(telephoneNumber=*))(|(cn=*a*b*)(cn=*b*a*)))', 'complex filter');
