#!perl

use strict;
use warnings;
use Test::More tests => 9;

use FindBin;
use lib "$FindBin::Bin/lib";
use UFL::Phonebook::TestEnv;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::Phonebook::Controller::Root');

$mech->get_ok('/', 'request for index page');

$mech->get('/this_does_not_exist');
$mech->title_like(qr/Not Found/, 'looks like a 404 page');
is($mech->status, 404, 'status code correct');

{
    local %ENV = %{ UFL::Phonebook::TestEnv->get };

    $mech->get_ok('/env', 'request for environment page');
    $mech->content_like(qr/\bdwc\@ufl.edu\b/, 'page contains expected REMOTE_USER value');
    $mech->content_like(qr/\bdwc\b/, 'page contains expected glid value');
    $mech->content_like(qr/\b13141570\b/, 'page contains expected ufid value');
    $mech->content_like(qr/\bT\b/, 'page contains expected primary_affiliation value');
}
