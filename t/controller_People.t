use strict;
use warnings;
use Test::More tests => 20;

use Test::WWW::Mechanize::Catalyst "Phonebook";

use_ok('Phonebook::Controller::People');

my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get_ok('/people/', 'request for people page');

$mech->get_ok('/people/search?query=test', 'request for search results');
$mech->title_like(qr/test/i, 'response title looks like search results');
$mech->content_like(qr/TEST,NAME/i, 'response body looks like search results');

$mech->get_ok('/people/search?query=mark trammell', 'request for full name search results');
$mech->title_like(qr/trammell/i, 'response title looks like search results');
$mech->content_like(qr/TRAMMELL\s+JR,MARK/i, 'response body looks like search results');

$mech->get_ok('/people/search?query=m. trammell', 'request for first initial, last name search results');
$mech->title_like(qr/trammell/i, 'response title looks like search results');
$mech->content_like(qr/TRAMMELL\s+JR,MARK/i, 'response body looks like search results');

$mech->get_ok('/people/SNJHVEWHH/', 'request for single person');
$mech->title_like(qr/TEST,NAME/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');

$mech->get_ok('/people/SNJHVEWHH/full/', 'request for full LDAP entry');
$mech->title_like(qr/TEST,NAME's Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok('/people/SNJHVEWHH/vcard/', 'request for vCard');
is($mech->ct, 'text/x-vcard', 'response Content-Type');
$mech->content_like(qr/TEST\\,NAME/i, 'response vCard data');
