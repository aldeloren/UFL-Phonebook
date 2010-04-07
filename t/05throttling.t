#!perl

use strict;
use warnings;
use Data::Throttler;
use Test::More tests => 6;

use Test::WWW::Mechanize::Catalyst "UFL::Phonebook";
my $mech = Test::WWW::Mechanize::Catalyst->new;

my $QUERY = 'tester';
my $UFID  = 'TVJVWHJJW';

# Override the default throttler so we can reasonably test
my $throttler = Data::Throttler->new(
   max_items => 5,
   interval  => 3600,
);

UFL::Phonebook->controller('People')->_throttler($throttler);

$mech->get_ok("/people/search?query=$QUERY");
$mech->get_ok("/people/$UFID/");
$mech->get_ok("/people/$UFID/full/");

$mech->get_ok("/people/search?query=$QUERY");
$mech->get_ok("/people/$UFID/");

$mech->get("/people/$UFID/vcard/");
is($mech->status, 503, 'user has been throttled');
