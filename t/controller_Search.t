use strict;
use warnings;
use Test::More tests => 3;

use_ok('Catalyst::Test', 'Phonebook');
use_ok('Phonebook::Controller::Search');

ok(request('search')->is_success);
