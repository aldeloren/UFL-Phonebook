use strict;
use warnings;
use Test::More tests => 3;

use_ok('Uf::Webadmin::Phonebook::Utilities');

my $EMAIL = 'webmaster@ufl.edu';
my $UFID = '12345678';

my $result = Uf::Webadmin::Phonebook::Utilities::spam_armor($EMAIL);
ok($result ne $EMAIL);

my $encoded = Uf::Webadmin::Phonebook::Utilities::encode_ufid($UFID);
my $decoded = Uf::Webadmin::Phonebook::Utilities::decode_ufid($encoded);
ok($UFID eq $decoded);
