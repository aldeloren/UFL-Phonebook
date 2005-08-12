use Test::More tests => 6;
use_ok('Uf::Webadmin::Phonebook::Filter');

my $sn = 'TEST';
my $cn = "$sn,TEST";

# One filter, no operator necessary
my $filter1 = Uf::Webadmin::Phonebook::Filter->new({
    cn => $cn,
});
ok($filter1->toString eq "(cn=$cn)");

# Two filters, default operator
my $filter2 = Uf::Webadmin::Phonebook::Filter->new({
    sn => $sn,
    cn => $cn,
});
print $filter2->toString, "\n";
ok($filter2->toString eq "(|(sn=$sn)(cn=$cn))" or $filter2->toString eq "(|(cn=$cn)(sn=$sn))");

# Two filters, specific operator
my $filter3 = Uf::Webadmin::Phonebook::Filter->new({
    sn => $sn,
    cn => $cn,
}, '&');
print $filter3->toString, "\n";
ok($filter3->toString eq "(&(sn=$sn)(cn=$cn))" or $filter3->toString eq "(&(cn=$cn)(sn=$sn))");

# Affiliation filter
my $filter4 = Uf::Webadmin::Phonebook::Filter->new({
    eduPersonPrimaryAffiliation => [ '-*-', 'affiliate' ],
});
print $filter4->toString, "\n";
ok($filter4->toString eq "(|(eduPersonPrimaryAffiliation=-*-)(eduPersonPrimaryAffiliation=affiliate))");

# Combine two filters
my $filter5 = Uf::Webadmin::Phonebook::Filter->new({
    $filter1,
    $filter4,    
}, '&');
fail();