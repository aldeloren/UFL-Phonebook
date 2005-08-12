use Test::More tests => 6;
use_ok('Uf::Webadmin::Phonebook::Filter');

# Values used in multiple tests
my $sn = 'TEST';
my $cn = "$sn,TEST";

# Filters used in multiple tests
my $simple = "(cn=$cn)";
my $affiliation = "(|(eduPersonPrimaryAffiliation=-*-)(eduPersonPrimaryAffiliation=affiliate))";


# One filter, no operator necessary
my $filter1 = Uf::Webadmin::Phonebook::Filter->new('|', {
    cn => $cn,
});
print $filter1->toString, "\n";
ok($filter1->toString eq $simple);

# Two filters, default operator
my $filter2 = Uf::Webadmin::Phonebook::Filter->new('|', {
    sn => $sn,
    cn => $cn,
});
print $filter2->toString, "\n";
ok($filter2->toString eq "(|(sn=$sn)(cn=$cn))" or $filter2->toString eq "(|(cn=$cn)(sn=$sn))");

# Two filters, specific operator
my $filter3 = Uf::Webadmin::Phonebook::Filter->new('&', {
    sn => $sn,
    cn => $cn,
});
print $filter3->toString, "\n";
ok($filter3->toString eq "(&(sn=$sn)(cn=$cn))" or $filter3->toString eq "(&(cn=$cn)(sn=$sn))");

# Affiliation filter
my $filter4 = Uf::Webadmin::Phonebook::Filter->new('|', {
    eduPersonPrimaryAffiliation => [ '-*-', 'affiliate' ],
});
print $filter4->toString, "\n";
ok($filter4->toString eq $affiliation);

# Combine two filters
my $filter5 = Uf::Webadmin::Phonebook::Filter->new('&',
    $filter1,
    $filter4,
);
print $filter5->toString, "\n";
ok($filter5->toString eq "(&$simple$affiliation)");