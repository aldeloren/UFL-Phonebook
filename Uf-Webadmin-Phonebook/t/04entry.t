use Test::More tests => 4;
use_ok('Uf::Webadmin::Phonebook::M::Person');
use_ok('Uf::Webadmin::Phonebook::Entry');

my $name = 'TEST,TEST';
my $mesg = Uf::Webadmin::Phonebook::M::Person->search("cn=$name");
ok(! $mesg->code, 'LDAP query');

my @entries = map { Uf::Webadmin::Phonebook::Entry->new($_) } $mesg->entries;
ok($entries[0]->{cn} eq $name, 'cn matches');
