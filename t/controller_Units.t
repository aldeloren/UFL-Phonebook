use strict;
use warnings;
use Test::More tests => 3;

use_ok('Catalyst::Test', 'Phonebook');
use_ok('Phonebook::Controller::Units');

ok(request('units')->is_success);
