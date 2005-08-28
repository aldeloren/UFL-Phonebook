use Test::More tests => 7;
use_ok('Uf::Webadmin::Phonebook::Filter');

# Values used in multiple tests
my $sn = 'TEST';
my $cn = "$sn,TEST";

# Filters used in multiple tests
my $simple      = "(cn=$cn)";
my $affiliation = "(&(eduPersonPrimaryAffiliation!=-*-)(eduPersonPrimaryAffiliation!=affiliate))";

# Storage for generated filter string
my $generated = '';

# Filter objects used in multiple tests
ok(my $filter    = Uf::Webadmin::Phonebook::Filter->new(), 'New filter, default logic');
ok(my $andFilter = Uf::Webadmin::Phonebook::Filter->new(logic => 'and'), 'New filter, specific logic');

$generated = $filter->where({
    cn => $cn,
});
print "$generated\n";
ok($generated eq $simple, 'Simple filter');

$generated = $filter->where({
    sn => $sn,
    cn => $cn,
});
print "$generated\n";
ok($generated eq "(|(sn=$sn)(cn=$cn))" or $generated eq "(|(cn=$cn)(sn=$sn))", 'Two filters, default operator');

$generated = $andFilter->where({
    sn => $sn,
    cn => $cn,
});
print "$generated\n";
ok($generated eq "(&(sn=$sn)(cn=$cn))" or $generated eq "(&(cn=$cn)(sn=$sn))", 'Two filters, specific operator');

$generated = $filter->where({
    eduPersonPrimaryAffiliation => [ {'!=', '-*-'}, {'!=', 'affiliate'} ],
});
print "$generated\n";
ok($generated eq $affiliation, 'Affiliation filter');

$generated = $andFilter->where({
    cn => $cn,
    eduPersonPrimaryAffiliation => [ {'!=', '-*-'}, {'!=', 'affiliate'} ],
});
print "$generated\n";
ok($generated eq '(&' . $simple . $affiliation . ')' or '(&' . $affiliation . $simple . ')', 'Combine simple and affiliation filters');
