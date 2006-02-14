use strict;
use warnings;
use Test::More tests => 20;

use Test::WWW::Mechanize::Catalyst 'Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('Phonebook::Controller::People');

my $QUERY = 'test';
my $CN    = 'TEST,NAME';
my $UFID  = 'SNJHVEWHH';
my $TITLE = 'TEST RECORD';

$mech->get_ok('/people/', 'request for people page');

$mech->get_ok("/people/search?query=$QUERY", 'request for search results');
$mech->title_like(qr/$QUERY/i, 'response title looks like search results');
$mech->content_like(qr/$CN/i, 'response body looks like search results');

$mech->get_ok('/people/search?query=john smith', 'request for full name search results');
$mech->title_like(qr/john smith/i, 'response title looks like search results');
$mech->content_like(qr/SMITH,JOHN/i, 'response body looks like search results');

$mech->get_ok('/people/search?query=j. smith', 'request for first initial, last name search results');
$mech->title_like(qr/smith/i, 'response title looks like search results');
$mech->content_like(qr/SMITH,JOHN/i, 'response body looks like search results');

$mech->get_ok("/people/$UFID/", 'request for single person');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');

$mech->get_ok("/people/$UFID/full/", 'request for full LDAP entry');
$mech->title_like(qr/${CN}'s Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');

$mech->get_ok("/people/$UFID/vcard/", 'request for vCard');
is($mech->ct, 'text/x-vcard', 'response Content-Type');
$mech->content_like(qr/TITLE:$TITLE/i, 'response vCard data');
