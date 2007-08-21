use strict;
use warnings;
use Test::More tests => 4;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::Phonebook::Controller::Root');

$mech->get_ok('/', 'request for index page');

$mech->get('/this_does_not_exist');
$mech->title_like(qr/Not Found/, 'looks like a 404 page');
is($mech->status, 404, 'status code correct');
