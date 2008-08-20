use strict;
use warnings;
use Test::More tests => 36;

use_ok('UFL::Phonebook::Util');

my $EMAIL = 'webmaster@ufl.edu';
my @UFIDS = qw/12345678 87654321 23456789 98765432 00000000 11111111 99999999 93205832 25597530/;

my $result = UFL::Phonebook::Util::spam_armor($EMAIL);
isnt($result, $EMAIL, 'protected email');

foreach my $ufid (@UFIDS) {
    my $encoded = UFL::Phonebook::Util::encode_ufid($ufid);
    my $decoded = UFL::Phonebook::Util::decode_ufid($encoded);
    is($decoded, $ufid, "encode, decode UFID ($ufid => $encoded => $decoded)");
}

is_deeply([ UFL::Phonebook::Util::tokenize_query('one') ], [ qw/one/ ], 'one token');
is_deeply([ UFL::Phonebook::Util::tokenize_query('One') ], [ qw/one/ ], 'one token, case normalization');
is_deeply([ UFL::Phonebook::Util::tokenize_query('ONE') ], [ qw/one/ ], 'one token, case normalization');
is_deeply([ UFL::Phonebook::Util::tokenize_query(' one') ], [ qw/one/ ], 'one token with leading space');
is_deeply([ UFL::Phonebook::Util::tokenize_query('one ') ], [ qw/one/ ], 'one token with trailing space');
is_deeply([ UFL::Phonebook::Util::tokenize_query(' one ') ], [ qw/one/ ], 'one token with leading and trailing space');
is_deeply([ UFL::Phonebook::Util::tokenize_query('one, ') ], [ qw/one/ ], 'one token with trailing comma');

is_deeply([ UFL::Phonebook::Util::tokenize_query('two tokens') ], [ qw/two tokens/ ], 'two tokens');
is_deeply([ UFL::Phonebook::Util::tokenize_query('Two TOkens') ], [ qw/two tokens/ ], 'two tokens, case normalization');
is_deeply([ UFL::Phonebook::Util::tokenize_query(' two tokens') ], [ qw/two tokens/ ], 'two tokens with leading space');
is_deeply([ UFL::Phonebook::Util::tokenize_query('two tokens ') ], [ qw/two tokens/ ], 'two tokens with trailing space');
is_deeply([ UFL::Phonebook::Util::tokenize_query(' two tokens ') ], [ qw/two tokens/ ], 'two tokens with leading and trailing space');
is_deeply([ UFL::Phonebook::Util::tokenize_query(' two   tokens ') ], [ qw/two tokens/ ], 'two tokens with leading, additional, and trailing space');
is_deeply([ UFL::Phonebook::Util::tokenize_query('tokens, two') ], [ qw/two tokens/ ], 'two tokens with comma and space');
is_deeply([ UFL::Phonebook::Util::tokenize_query('tokens,two') ], [ qw/two tokens/ ], 'two tokens with comma');
is_deeply([ UFL::Phonebook::Util::tokenize_query('tokeNS,Two') ], [ qw/two tokens/ ], 'two tokens with comma and case normalization');

is_deeply([ UFL::Phonebook::Util::tokenize_query('thr ee tokens') ], [ qw/thr ee tokens/ ], 'three tokens');
is_deeply([ UFL::Phonebook::Util::tokenize_query('Thr Ee Tokens') ], [ qw/thr ee tokens/ ], 'three tokens, case normalization');
is_deeply([ UFL::Phonebook::Util::tokenize_query(' thr ee tokens') ], [ qw/thr ee tokens/ ], 'three tokens with leading space');
is_deeply([ UFL::Phonebook::Util::tokenize_query('thr ee tokens ') ], [ qw/thr ee tokens/ ], 'three tokens with trailing space');
is_deeply([ UFL::Phonebook::Util::tokenize_query(' thr ee tokens ') ], [ qw/thr ee tokens/ ], 'three tokens with leading and trailing space');
is_deeply([ UFL::Phonebook::Util::tokenize_query(' thr   ee   tokens ') ], [ qw/thr ee tokens/ ], 'three tokens with leading, additional, and trailing space');
is_deeply([ UFL::Phonebook::Util::tokenize_query('tokens, thr ee') ], [ qw/thr ee tokens/ ], 'three tokens with comma and space');
is_deeply([ UFL::Phonebook::Util::tokenize_query('tokens,thr ee') ], [ qw/thr ee tokens/ ], 'three tokens with comma');
is_deeply([ UFL::Phonebook::Util::tokenize_query('tOKens,THr eE') ], [ qw/thr ee tokens/ ], 'three tokens with comma and case normalization');
