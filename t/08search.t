use strict;
use warnings;
use Test::More tests => 15;

use Test::WWW::Mechanize::Catalyst "Phonebook";
my $mech = Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok('/people/search?query=trammell', {}, 'request for search results');
$mech->title_like(qr/trammell/i, 'response title looks like search results');
$mech->content_like(qr/TRAMMELL JR,MARK R/i, 'response body looks like search results');

$mech->get_ok('/people/search?query=mark trammell', {}, 'request for full name search results');
$mech->title_like(qr/trammell/i, 'response title looks like search results');
$mech->content_like(qr/TRAMMELL\s+JR,MARK\s+R/i, 'response body looks like search results');

$mech->get_ok('/people/JVNJEEWNV/', {}, 'request for single person');
$mech->title_like(qr/TRAMMELL\s+JR,MARK\s+R/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');

$mech->get_ok('/people/JVNJEEWNV/full/', {}, 'request for full LDAP entry');
$mech->title_like(qr/TRAMMELL\s+JR,MARK\s+R's Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok('/people/JVNJEEWNV/vcard/', {}, 'request for vCard');
is($mech->ct, 'text/x-vcard', 'response Content-Type');
$mech->content_like(qr/TRAMMELL\s+JR\\,MARK\s+R/i, 'response vCard data');
