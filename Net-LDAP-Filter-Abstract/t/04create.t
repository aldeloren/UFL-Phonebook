use strict;
use Net::LDAP::Filter::Abstract;
use Test::More tests => 6;

my $filter = Net::LDAP::Filter::Abstract->new('&');
ok($filter);
$filter->add(qw/objectClass = person/);
ok($filter->as_string eq '(objectClass=person)');

$filter->add(Net::LDAP::Filter::Abstract->new('!')->add(qw/telephoneNumber = */));
ok($filter->as_string eq '(&(objectClass=person)(!(telephoneNumber=*)))');

my $filter2 = Net::LDAP::Filter::Abstract->new('|');
ok($filter2);
$filter2->add(qw/cn = *a*b*/);
$filter2->add(qw/cn = *b*a*/);
ok($filter2->as_string eq '(|(cn=*a*b*)(cn=*b*a*))');

$filter->add($filter2);
ok($filter->as_string eq '(&(objectClass=person)(!(telephoneNumber=*))(|(cn=*a*b*)(cn=*b*a*)))');
