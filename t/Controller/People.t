use strict;
use warnings;
use Test::More tests => 3;

use_ok('Catalyst::Test', 'Uf::Webadmin::Phonebook');
use_ok('Uf::Webadmin::Phonebook::Controller::People');

ok(request('people')->is_success);
