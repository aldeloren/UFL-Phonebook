use strict;
use warnings;
use Test::More tests => 14;

use Test::WWW::Mechanize::Catalyst 'Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('Phonebook::Controller::People');

my $QUERY = 'oaa';
my $O     = 'PV-OAA APPLICATION DEVELOP';
my $PSID  = '02010601';

$mech->get_ok('/units/', 'request for units page');


$mech->get_ok("/units/search?query=$QUERY", 'request for search results');
$mech->title_like(qr/$QUERY/i, 'response title looks like search results');
$mech->content_like(qr/$O/i, 'response body looks like search results');


$mech->get_ok("/units/$PSID/", 'request for single unit by PeopleSoft ID');
$mech->title_like(qr/$O/i, 'response title looks like a single unit entry');
$mech->content_like(qr/general information/i, 'response looks like a single unit entry');

$mech->get("/units/$PSID/show/", 'request for single unit, invalid action');
is($mech->status, 404, 'request for single unit, invalid action 404s');

$mech->get("/units/$PSID/full/", 'request for full LDAP entry');
$mech->title_like(qr/Full LDAP Entry for $O/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok("/units/$PSID/people/", 'request for people in unit');
$mech->title_like(qr/$O/i, 'response title looks like results for people in unit');
$mech->content_like(qr/$O/i, 'response looks like results for people in unit');
