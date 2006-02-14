use strict;
use warnings;
use Test::More tests => 26;

use Test::WWW::Mechanize::Catalyst "Phonebook";
my $mech = Test::WWW::Mechanize::Catalyst->new;

my $QUERY = 'test';
my $CN    = 'TESTER,AT A';
my $UID   = 'attest1';
my $UFID  = 'TVJVWHJJW';

$mech->get_ok('/display_form.cgi', 'request for main form was successful');
$mech->content_like(qr/div id="priSearch"/i, 'response body looks like main form');

$mech->get_ok("/display_form.cgi?person=$QUERY", 'request for search results was successful');
$mech->title_like(qr/$QUERY/i, 'response title looks like search results');
$mech->content_like(qr/$CN/i, 'response body looks like search results');

$mech->get_ok("/search?person=$QUERY", 'request for search results was successful');
$mech->title_like(qr/$QUERY/i, 'response title looks like search results');
$mech->content_like(qr/$CN/i, 'response body looks like search results');

$mech->get_ok("/show.cgi?$UFID", 'request for a single person by encoded UFID');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');

$mech->get_ok("/show-full.cgi?$UFID", 'request for a full LDAP entry by encoded UFID');
$mech->title_like(qr/${CN}'s Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok("/show.cgi?$UID", 'request for a single person by uid');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');

$mech->get_ok("/show-full.cgi?$UID", 'request for a full entry by uid');
$mech->title_like(qr/${CN}'s Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok("/show.cgi?$CN", 'request for a single person by full name');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');

$mech->get_ok("/show-full.cgi?$CN", 'request for a full entry by full name');
$mech->title_like(qr/${CN}'s Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');
