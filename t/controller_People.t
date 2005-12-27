use strict;
use warnings;
use Test::More tests => 3;

use_ok('Catalyst::Test', 'Phonebook');
use_ok('Phonebook::Controller::People');

ok(request('people')->is_success);
