use strict;
use warnings;
use Test::More tests => 17;

use_ok('Phonebook::Util');

my $EMAIL = 'webmaster@ufl.edu';
my $UFID = '12345678';

my $result = Phonebook::Util::spam_armor($EMAIL);
isnt($result, $EMAIL, 'protected email');

my $encoded = Phonebook::Util::encode_ufid($UFID);
my $decoded = Phonebook::Util::decode_ufid($encoded);
is($decoded, $UFID, 'encode, decode UFID');

is_deeply([ Phonebook::Util::tokenize_query('one') ], [ qw/one/ ], 'one token');
is_deeply([ Phonebook::Util::tokenize_query('One') ], [ qw/one/ ], 'one token, case normalization');
is_deeply([ Phonebook::Util::tokenize_query('ONE') ], [ qw/one/ ], 'one token, case normalization');
is_deeply([ Phonebook::Util::tokenize_query('one, ') ], [ qw/one/ ], 'one token with trailing comma');

is_deeply([ Phonebook::Util::tokenize_query('two tokens') ], [ qw/two tokens/ ], 'two tokens');
is_deeply([ Phonebook::Util::tokenize_query('Two TOkens') ], [ qw/two tokens/ ], 'two tokens, case normalization');
is_deeply([ Phonebook::Util::tokenize_query('tokens, two') ], [ qw/tokens two/ ], 'two tokens with comma and space');
is_deeply([ Phonebook::Util::tokenize_query('tokens,two') ], [ qw/tokens two/ ], 'two tokens with comma');
is_deeply([ Phonebook::Util::tokenize_query('tokeNS,Two') ], [ qw/tokens two/ ], 'two tokens with comma and case normalization');

is_deeply([ Phonebook::Util::tokenize_query('thr ee tokens') ], [ qw/thr ee tokens/ ], 'three tokens');
is_deeply([ Phonebook::Util::tokenize_query('Thr Ee Tokens') ], [ qw/thr ee tokens/ ], 'three tokens, case normalization');
is_deeply([ Phonebook::Util::tokenize_query('tokens, thr ee') ], [ qw/tokens thr ee/ ], 'three tokens with comma and space');
is_deeply([ Phonebook::Util::tokenize_query('tokens,thr ee') ], [ qw/tokens thr ee/ ], 'three tokens with comma');
is_deeply([ Phonebook::Util::tokenize_query('tOKens,THr eE') ], [ qw/tokens thr ee/ ], 'three tokens with comma and case normalization');
