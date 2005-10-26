use strict;
use warnings;
use Test::More tests => 2;

use_ok('Catalyst::Test', 'Uf::Webadmin::Phonebook');

ok(request('/')->is_success);
