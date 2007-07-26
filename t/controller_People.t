use strict;
use warnings;
use Test::More tests => 61;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::Phonebook::Controller::People');

my $QUERY        = 'tester';
my $CN           = 'TESTER,AT A';
my $UID          = 'attest1';
my $UFID         = '59831351';
my $ENCODED_UFID = 'TVJVWHJJW';
my $UNIT_PSID    = '02010601';
my $UNIT_UFID    = 'UETHHG63';
my $UNIT_O       = 'PV-OAA APPLICATION DEVELOP';

$mech->get_ok('/people/', 'request for people page');


$mech->get_ok("/people/search?query=$QUERY", 'request for search results');
$mech->title_like(qr/$QUERY/i, 'response title looks like search results');
$mech->content_like(qr/$CN/i, 'response body looks like search results');


$mech->get_ok('/people/search?query=AT A. TESTER', 'request for "first name middle initial. last name" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=TESTER, AT A.', 'request for "last name, first name middle initial." search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=AT A TESTER', 'request for "first name middle initial last name" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=TESTER, AT A', 'request for "last name, first name middle initial" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=AT TESTER', 'request for "first name last name" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=TESTER, AT', 'request for "last name, first name" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=TESTER,AT', 'request for "last name,first name" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=A. TESTER', 'request for "first initial. last name" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=TESTER, A.', 'request for "last name, first initial." search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=TESTER,A.', 'request for "last name,first initial." search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=A TESTER', 'request for "first initial last name" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=TESTER, A', 'request for "last name, first initial" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');

$mech->get_ok('/people/search?query=TESTER,A', 'request for "last name,first initial" search results');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/$CN/i, 'response body looks like a single person entry');


$mech->get("/people/$UFID/", 'request for single person by UFID');
is($mech->status, 404, 'request for single person by UFID 404s');

$mech->get_ok("/people/$ENCODED_UFID/", 'request for single person');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');

$mech->get("/people/$ENCODED_UFID/show/", 'request for single person, invalid action');
is($mech->status, 404, 'request for single person, invalid action 404s');

$mech->get_ok("/people/$ENCODED_UFID/full/", 'request for full LDAP entry');
$mech->title_like(qr/${CN}'s Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok("/people/$ENCODED_UFID/vcard/", 'request for vCard');
is($mech->ct, 'text/x-vcard', 'response Content-Type is a vCard');
$mech->content_like(qr/NICKNAME:$UID/i, 'response looks like vCard data');


$mech->get_ok("/people/unit/$UNIT_PSID/", 'request for people in unit');
$mech->title_like(qr/$UNIT_O/i, 'response title looks like results for people in unit');
$mech->content_like(qr/$UNIT_O/i, 'response looks like results for people in unit');

$mech->get_ok("/people/unit/$UNIT_UFID/", 'request for people in unit');
$mech->title_like(qr/$UNIT_O/i, 'response title looks like results for people in unit');
$mech->content_like(qr/$UNIT_O/i, 'response looks like results for people in unit');
