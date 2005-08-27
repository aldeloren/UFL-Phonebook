use strict;
use Catalyst::Model::LDAP;
use Test::More tests => 3;

ok(my $ldap = Catalyst::Model::LDAP->new());
$ldap->config(
    host => 'ldap.ufl.edu',
    base => 'ou=People,dc=ufl,dc=edu',
);

my $rv = $ldap->search('(sn=Test)');
ok(not $rv->code);
ok(scalar $rv->entries > 0);
