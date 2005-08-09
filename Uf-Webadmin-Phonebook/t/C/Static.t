use Test::More tests => 8;
use_ok(Catalyst::Test, 'Uf::Webadmin::Phonebook');
use_ok('Uf::Webadmin::Phonebook::C::Static');

ok(request('static')->is_success);

my $cssResponse = request('/static/css/basic.css');
ok($cssResponse->is_success);
ok($cssResponse->header('Content-Type') eq 'text/css');

my $imgResponse = request('/static/images/smallWordmark.gif');
ok($imgResponse->is_success);
ok($imgResponse->header('Content-Type') eq 'image/gif');

ok(request('/favicon.ico')->is_success);
