#!perl

use strict;
use warnings;
use Data::Throttler;
use Test::More tests => 12;

use Test::WWW::Mechanize::Catalyst "UFL::Phonebook";
my $mech = Test::WWW::Mechanize::Catalyst->new;

my $QUERY = 'tester';
my $UFID  = 'TVJVWHJJW';

# Override the default throttler so we can reasonably test
my $throttler = Data::Throttler->new(
   max_items => 5,
   interval  => 3600,
);

UFL::Phonebook->controller('Throttle')->_throttler($throttler);

$mech->get_ok("/people/search?query=$QUERY");
$mech->get_ok("/people/$UFID/");
$mech->get_ok("/people/$UFID/full/");

$mech->get_ok("/people/search?query=$QUERY");
$mech->get_ok("/people/$UFID/");

$mech->get("/people/$UFID/vcard/");
is($mech->status, 503, 'user has been throttled');

$mech->get_ok('/throttle/');
$mech->content_like(qr/127.0.0.1/, 'displaying user as throttled');
$mech->form_with_fields(qw/ip/);
$mech->submit_form_ok({}, 'removing user from throttle list');

$mech->get_ok("/people/search?query=$QUERY");
$mech->get_ok("/people/$UFID/");
$mech->get_ok("/people/$UFID/full/");
