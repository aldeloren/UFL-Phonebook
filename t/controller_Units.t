use strict;
use warnings;
use Test::More tests => 25;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

my $QUERY = 'oaa';
my $O     = 'PV-OAA APPLICATION DEVELOP';
my $PSID  = '02010601';
my $UFID  = 'UETHHG63';


$mech->get_ok('/units/', 'request for units page');


$mech->get_ok("/units/search?query=$QUERY", 'request for search results');
$mech->title_like(qr/$QUERY/i, 'response title looks like search results');
$mech->content_like(qr/$O/i, 'response body looks like search results');


$mech->get_ok("/units/$PSID/", 'request for single unit by PeopleSoft ID');
$mech->title_like(qr/$O/i, 'response title looks like a single unit entry');
$mech->content_like(qr/general information/i, 'response looks like a single unit entry');

$mech->get("/units/$PSID/show/", 'request for single unit, invalid action');
is($mech->status, 404, 'request for single unit, invalid action 404s');

$mech->get_ok("/units/$PSID/full/", 'request for full LDAP entry');
$mech->title_like(qr/Full LDAP Entry for $O/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok("/units/$PSID/people/", 'request for people in unit');
$mech->title_like(qr/$O/i, 'response title looks like results for people in unit');
$mech->content_like(qr/$O/i, 'response looks like results for people in unit');


$mech->get_ok("/units/$UFID/", 'request for single unit by UFID');
$mech->title_like(qr/$O/i, 'response title looks like a single unit entry');
$mech->content_like(qr/general information/i, 'response looks like a single unit entry');

$mech->get("/units/$UFID/show/", 'request for single unit, invalid action');
is($mech->status, 404, 'request for single unit, invalid action 404s');

$mech->get_ok("/units/$UFID/full/", 'request for full LDAP entry');
$mech->title_like(qr/Full LDAP Entry for $O/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok("/units/$UFID/people/", 'request for people in unit');
$mech->title_like(qr/$O/i, 'response title looks like results for people in unit');
$mech->content_like(qr/$O/i, 'response looks like results for people in unit');
$mech->content_like(qr|<a href="[^"]+/people/[A-Z]{8,9}/|i, 'response contains at least one link to a person');
