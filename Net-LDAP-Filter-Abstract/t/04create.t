use strict;
use Data::Dumper;
use Net::LDAP::Filter::Abstract;
use Test::More tests => 8;

my $filter = Net::LDAP::Filter::Abstract->new('&');
ok($filter);
$filter->add(qw/objectClass = person/);
ok($filter->as_string eq '(objectClass=person)');

my $filter2 = Net::LDAP::Filter::Abstract->new('!')->add(qw/telephoneNumber = */);
ok($filter2);
ok($filter2->as_string eq '(!(telephoneNumber=*))');

$filter->add($filter2);
ok($filter->as_string eq '(&(objectClass=person)(!(telephoneNumber=*)))');

my $filter3 = Net::LDAP::Filter::Abstract->new('|');
ok($filter3);
$filter3->add(qw/cn = *a*b*/);
$filter3->add(qw/cn = *b*a*/);
ok($filter3->as_string eq '(|(cn=*a*b*)(cn=*b*a*))');

$filter->add($filter3);
ok($filter->as_string eq '(&(objectClass=person)(!(telephoneNumber=*))(|(cn=*a*b*)(cn=*b*a*)))');
