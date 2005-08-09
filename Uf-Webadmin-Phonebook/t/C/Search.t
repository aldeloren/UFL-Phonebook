use Test::More tests => 3;
use_ok(Catalyst::Test, 'Uf::Webadmin::Phonebook');
use_ok('Uf::Webadmin::Phonebook::C::Search');

ok(request('search')->is_success);
