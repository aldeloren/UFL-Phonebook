use Test::More tests => 3;
use_ok('Uf::Webadmin::Phonebook::Utilities');

my $email = 'webmaster@ufl.edu';
my $result = Uf::Webadmin::Phonebook::Utilities::spamArmor($email);
ok($result ne $email);

my $ufid = '12345678';
my $encoded = Uf::Webadmin::Phonebook::Utilities::encodeUfid($ufid);
my $decoded = Uf::Webadmin::Phonebook::Utilities::decodeUfid($encoded);
ok($ufid eq $decoded);
