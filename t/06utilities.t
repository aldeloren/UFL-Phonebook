use strict;
use warnings;
use Test::More tests => 3;

use_ok('Phonebook::Utilities');

my $EMAIL = 'webmaster@ufl.edu';
my $UFID = '12345678';

my $result = Phonebook::Utilities::spam_armor($EMAIL);
isnt($result, $EMAIL, 'protected email');

my $encoded = Phonebook::Utilities::encode_ufid($UFID);
my $decoded = Phonebook::Utilities::decode_ufid($encoded);
is($decoded, $UFID, 'encode, decode UFID');
