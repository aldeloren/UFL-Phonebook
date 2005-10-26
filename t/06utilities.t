use strict;
use warnings;
use Test::More tests => 3;

use_ok('Uf::Webadmin::Phonebook::Utilities');

my $EMAIL = 'webmaster@ufl.edu';
my $UFID = '12345678';

my $result = Uf::Webadmin::Phonebook::Utilities::spamArmor($EMAIL);
ok($result ne $EMAIL);

my $encoded = Uf::Webadmin::Phonebook::Utilities::encodeUfid($UFID);
my $decoded = Uf::Webadmin::Phonebook::Utilities::decodeUfid($encoded);
ok($UFID eq $decoded);
