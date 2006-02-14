use strict;
use warnings;
use Test::More tests => 20;

use Test::WWW::Mechanize::Catalyst "Phonebook";
my $mech = Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok('/display_form.cgi', 'request for main form was successful');
$mech->content_like(qr/div id="priSearch"/i, 'response body looks like main form');

$mech->get_ok('/display_form.cgi?person=test', 'request for search results was successful');
$mech->title_like(qr/test/i, 'response title looks like search results');
$mech->content_like(qr/TEST,NAME/i, 'response body looks like search results');

$mech->get_ok('/search?person=test', 'request for search results was successful');
$mech->title_like(qr/test/i, 'response title looks like search results');
$mech->content_like(qr/TEST,NAME/i, 'response body looks like search results');

$mech->get_ok('/show.cgi?attest1', 'request for a single person by uid');
$mech->title_like(qr/TESTER,AT\s+A/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');

$mech->get_ok('/show-full.cgi?attest1', 'request for a full entry by uid');
$mech->title_like(qr/TESTER,AT\s+A's Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok('/show.cgi?TVJVWHJJW', 'request for a single person by encoded UFID');
$mech->title_like(qr/TESTER,AT\s+A/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');

$mech->get_ok('/show-full.cgi?TVJVWHJJW', 'request for a full LDAP entry by encoded UFID');
$mech->title_like(qr/TESTER,AT\s+A's Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');
