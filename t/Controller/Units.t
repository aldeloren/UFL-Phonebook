use strict;
use warnings;
use Test::More tests => 3;

use_ok('Catalyst::Test', 'Uf::Webadmin::Phonebook');
use_ok('Uf::Webadmin::Phonebook::Controller::Units');

ok(request('units')->is_success);
