use strict;
use warnings;
use Test::More tests => 98;
use Text::vCard::Addressbook;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

my $QUERY        = 'tester';
my $CN           = 'Tester,AT A';
my $UID          = 'attest1';
my $UFID         = '59831351';
my $ENCODED_UFID = 'TVJVWHJJW';
my $EMAIL        = 'attest1@ufl.edu';
my $O            = 'IT-AT ACADEMIC TECHNOLOGY';

my $UNIT_PSID    = '14100100';
my $UNIT_UFID    = 'EWAAGGF1';
my $UNIT_O       = 'IT-WEB ADMIN OFFICE';


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

SKIP: {
    skip 'http://phonebook.ufl.edu/people/SJTNTVVET/', 18;

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
}

$mech->get_ok('/people/search?query=smith', 'request for common name search results');
$mech->title_like(qr/smith/i, 'request looks like search results');
$mech->content_like(qr/smith/i, 'response body looks like search results');
$mech->content_like(qr/too many people/i, 'response body contains warning');
$mech->content_like(qr|, <a href="[^"]+/units/[A-Z0-9]{8}/|i, 'response body contains a link to a unit');
$mech->content_unlike(qr/REGISTRAR STUDENTS/i, 'response body does not contain useless unit names');


$mech->get("/people/$UFID/", 'request for single person by UFID');
is($mech->status, 404, 'request for single person by UFID 404s');

$mech->get_ok("/people/$ENCODED_UFID/", 'request for single person');
$mech->title_like(qr/$CN/i, 'response title looks like a single person entry');
$mech->content_like(qr/general information/i, 'response looks like a single person entry');
$mech->content_like(qr|href="[^"]+/units/14200000/">IT-AT ACADEMIC TECHNOLOGY|i, 'response contains a unit reference');
$mech->content_unlike(qr/--UNKNOWN--/i, 'response does not contain unknown information');

$mech->get("/people/$ENCODED_UFID/show/", 'request for single person, invalid action');
is($mech->status, 404, 'request for single person, invalid action 404s');

$mech->get_ok("/people/$ENCODED_UFID/full/", 'request for full LDAP entry');
$mech->title_like(qr/${CN}'s Full LDAP Entry/i, 'response title looks like a full LDAP entry');
$mech->content_like(qr/LDAP Entry/i, 'response looks like a full LDAP entry');
$mech->content_unlike(qr/--UNKNOWN--/i, 'response does not contain unknown information');

test_vcard_download($mech, $ENCODED_UFID, $CN, $UID, $EMAIL, $O);

# Test vCard download for person who has no uid
test_vcard_download($mech, 'SNJHVEWHH', 'Test,Name');

$mech->get_ok("/people/unit/$UNIT_PSID/", 'request for people in unit');
$mech->title_like(qr/$UNIT_O/i, 'response title looks like results for people in unit');
$mech->content_like(qr/$UNIT_O/i, 'response looks like results for people in unit');

$mech->get_ok("/people/unit/$UNIT_UFID/", 'request for people in unit');
$mech->title_like(qr/$UNIT_O/i, 'response title looks like results for people in unit');
$mech->content_like(qr/$UNIT_O/i, 'response looks like results for people in unit');


# Test filtering of test LDAP entries
{
    my $controller = UFL::Phonebook->controller('People');

    # Reset the filter list to get a full view
    my $filter_key = $controller->filter_key;
    my $filter_values = $controller->filter_values;
    $controller->filter_values([]);

    $mech->get_ok("/people/search?query=alligator");
    $mech->content_like(qr|/people/WVWNENEVH/|i, 'search results contain record for UFID 09704400');
    $mech->content_like(qr|/people/VTESVTSNJ/|i, 'search results contain record for UFID 89074910');
    $mech->get_ok('/people/WVWNENEVH/', 'found single view for UFID 09704400');
    $mech->get_ok('/people/VTESVTSNJ/', 'found single view for UFID 89074910');

    # Set the filter list
    $controller->filter_key('uflEduUniversityId');
    $controller->filter_values([ qw/09704400 89074910/ ]);

    $mech->get_ok("/people/search?query=alligator");
    $mech->content_unlike(qr|/people/WVWNENEVH/|i, 'search results contain record for UFID 09704400');
    $mech->content_unlike(qr|/people/VTESVTSNJ/|i, 'search results contain record for UFID 89074910');
    $mech->get('/people/WVWNENEVH/');
    is($mech->status, 404, 'single view for UFID 09704400 returned 404');
    $mech->get('/people/VTESVTSNJ/');
    is($mech->status, 404, 'single view for UFID 89074910 returned 404');

    # Restore the previous filter list
    $controller->filter_key($filter_key);
    $controller->filter_values($filter_values);
}

sub test_vcard_download {
    my ($mech, $encoded_ufid, $cn, $uid, $email, $o) = @_;

    $mech->get_ok("/people/$encoded_ufid/vcard/", 'request for vCard');
    is($mech->ct, 'text/x-vcard', 'response Content-Type is a vCard');
    $mech->content_like(qr/BEGIN:vCard/i, 'response looks like vCard data');

    my $address_book = Text::vCard::Addressbook->new({ source_text => $mech->content });

    my @vcards = $address_book->vcards;
    is(@vcards, 1, 'found one vCard');

    my $vcard = $vcards[0];
    is($vcard->fullname, $cn, 'full name matches');
    is($vcard->nickname, $uid, 'nickname matches');

    # Email information
    my @emails = $vcard->get({ node_type => 'email' });
    is(@emails, 1, 'found an email address');
    if (defined $emails[0]) {
        is($emails[0]->value, $email, 'email address matches');
    }
    else {
        is($emails[0], $email, 'we expected no email address');
    }

    # Unit information
    my @orgs = $vcard->get({ node_type => 'org' });
    is(@orgs, 1, 'found an organization');

    my @units = $orgs[0]->unit;
    is(@units, 1, 'found a unit');
    is($units[0][0], $o, 'unit name matches');
}
