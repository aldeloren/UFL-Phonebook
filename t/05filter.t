use strict;
use Test::More tests => 9;
use_ok('Uf::Webadmin::Phonebook::Filter::Abstract');

my $filter = Uf::Webadmin::Phonebook::Filter::Abstract->new;
ok($filter);
$filter->add(qw/objectClass = person/);
ok($filter->as_string eq '(objectClass=person)');

my $filter2 = Uf::Webadmin::Phonebook::Filter::Abstract->new('!')->add(qw/telephoneNumber = */);
ok($filter2);
ok($filter2->as_string eq '(!(telephoneNumber=*))');

$filter->add($filter2);
ok($filter->as_string eq '(&(objectClass=person)(!(telephoneNumber=*)))');

my $filter3 = Uf::Webadmin::Phonebook::Filter::Abstract->new('|');
ok($filter3);
$filter3->add(qw/cn = *a*b*/);
$filter3->add(qw/cn = *b*a*/);
ok($filter3->as_string eq '(|(cn=*a*b*)(cn=*b*a*))');

$filter->add($filter3);
ok($filter->as_string eq '(&(objectClass=person)(!(telephoneNumber=*))(|(cn=*a*b*)(cn=*b*a*)))');
