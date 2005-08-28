use strict;
use Net::LDAP::Filter::Abstract;
use Test::More tests => 4;

my $filter = Net::LDAP::Filter::Abstract->new('&');
$filter->addChild('objectClass', '=', 'person');
ok($filter->as_string eq '(objectClass=person)');

$filter->addChild(Net::LDAP::Filter::Abstract->new('!')->addChild(qw/telephoneNumber = */));
ok($filter->as_string eq '(&(objectClass=person)(!(telephoneNumber=*)))');

my $filter2 = Net::LDAP::Filter::Abstract->new('|');
$filter2->addChild(qw/cn = *a*b*/);
$filter2->addChild(qw/cn = *b*a*/);
ok($filter2->as_string eq '(|(cn=*a*b*)(cn=*b*a*))');

$filter->addChild($filter2);
ok($filter->as_string eq '(&(objectClass=person)(!(telephoneNumber=*))(|(cn=*a*b*)(cn=*b*a*)))');
