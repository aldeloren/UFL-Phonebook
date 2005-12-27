use strict;
use warnings;
use Test::More tests => 3;

use_ok('Phonebook::Util');

my $EMAIL = 'webmaster@ufl.edu';
my $UFID = '12345678';

my $result = Phonebook::Util::spam_armor($EMAIL);
isnt($result, $EMAIL, 'protected email');

my $encoded = Phonebook::Util::encode_ufid($UFID);
my $decoded = Phonebook::Util::decode_ufid($encoded);
is($decoded, $UFID, 'encode, decode UFID');
