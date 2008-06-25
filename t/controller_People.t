use strict;
use warnings;
use Test::More tests => 101;
use Text::vCard::Addressbook;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::Phonebook::Controller::People');

my $QUERY        = 'tester';
my $CN           = 'Tester,AT A';
my $UID          = 'attest1';
my $UFID         = '59831351';
my $ENCODED_UFID = 'TVJVWHJJW';
my $EMAIL        = 'attest1@ufl.edu';
my $O            = 'IT-AT ACADEMIC TECHNOLOGY';

my $UNIT_PSID    = '02010601';
my $UNIT_UFID    = 'UETHHG63';
my $UNIT_O       = 'PV-OAA APPLICATION DEVELOP';

my $controller = UFL::Phonebook::Controller::People->new({ max_permuted_tokens => 10 });
isa_ok($controller, 'UFL::Phonebook::BaseController');
is($controller->max_permuted_tokens, 10, 'set maximum number of tokens allowed in permuting query');

# Test default filter restriction
{
    my $filter = $controller->_get_restriction;
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-)))", 'default restriction filter matches');
}

# Test simple filter generation
{
    my $filter = $controller->filter('cn', '=', $CN);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(cn=$CN)(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter matches');
}

# Test filter generation for query with one word
{
    my $filter = $controller->_parse_query($QUERY);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(sn=$QUERY*)(uid=$QUERY)(mail=$QUERY\@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for one-word query matches');
}

# Test filter generation for query with two words
{
    my $filter = $controller->_parse_query('First Last');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(&(givenName=*first*)(sn=last*))(cn=last*, first*)(cn=last*,first*)(mail=firstlast\@*)(mail=first-last\@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for two-word query matches');
}

# Test filter generation for query with two comma-separated words
{
    my $filter = $controller->_parse_query('Last, First');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(&(givenName=*first*)(sn=last*))(cn=last*, first*)(cn=last*,first*)(mail=firstlast\@*)(mail=first-last\@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for two-word query with comma matches');
}

# Test filter generation for query with three words
{
    my $filter = $controller->_parse_query('First M. Last');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(sn=First M. Last*)(&(givenName=*first*)(sn=m last*))(cn=m last*, *first*)(cn=m last*,*first*)(mail=firstm last\@*)(mail=first-m last\@*)(&(givenName=*first m*)(sn=last*))(cn=last*, *first m*)(cn=last*,*first m*)(mail=first mlast@*)(mail=first m-last@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for three-word query matches');
}

# Test filter generation for query with three comma-separated words
{
    my $filter = $controller->_parse_query('Last,First M.');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(sn=Last,First M.*)(&(givenName=*first*)(sn=m last*))(cn=m last*, *first*)(cn=m last*,*first*)(mail=firstm last\@*)(mail=first-m last\@*)(&(givenName=*first m*)(sn=last*))(cn=last*, *first m*)(cn=last*,*first m*)(mail=first mlast@*)(mail=first m-last@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for three-word query matches');
}

# Test filter generation for old show.cgi-style UFID query
{
    my $filter = $controller->_get_show_cgi_filter($ENCODED_UFID);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(uflEduUniversityId=$UFID)(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for show.cgi UFID query matches');
}

# Test filter generation for old show.cgi-style uid query
{
    my $filter = $controller->_get_show_cgi_filter($UID);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(uid=$UID)(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for show.cgi uid query matches');
}

# Test filter generation for old show.cgi-style name query
{
    my $filter = $controller->_get_show_cgi_filter('AT+A.+TESTER');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(cn=TESTER,AT A.*)(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for show.cgi name query matches');
}

# Test filter generation for old show.cgi-style name query
{
    eval { my $filter = $controller->_get_show_cgi_filter('something invalid') };
    ok($@, 'invalid show.cgi query threw an error');
}

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

$mech->get_ok("/people/$ENCODED_UFID/vcard/", 'request for vCard');
is($mech->ct, 'text/x-vcard', 'response Content-Type is a vCard');
$mech->content_like(qr/NICKNAME:$UID/i, 'response looks like vCard data');
{
    my $address_book = Text::vCard::Addressbook->new({ source_text => $mech->content });

    my @vcards = $address_book->vcards;
    is(@vcards, 1, 'found one vCard');

    my $vcard = $vcards[0];
    is($vcard->fullname, $CN, 'full name matches');
    is($vcard->nickname, $UID, 'nickname matches');

    # Email information
    my @emails = $vcard->get({ node_type => 'email' });
    is(@emails, 1, 'found an email address');
    is($emails[0]->value, $EMAIL, 'email address matches');

    # Unit information
    my @orgs = $vcard->get({ node_type => 'org' });
    is(@orgs, 1, 'found an organization');

    my @units = $orgs[0]->unit;
    is(@units, 1, 'found a unit');
    is($units[0][0], $O, 'unit name matches');
}


$mech->get_ok("/people/unit/$UNIT_PSID/", 'request for people in unit');
$mech->title_like(qr/$UNIT_O/i, 'response title looks like results for people in unit');
$mech->content_like(qr/$UNIT_O/i, 'response looks like results for people in unit');

$mech->get_ok("/people/unit/$UNIT_UFID/", 'request for people in unit');
$mech->title_like(qr/$UNIT_O/i, 'response title looks like results for people in unit');
$mech->content_like(qr/$UNIT_O/i, 'response looks like results for people in unit');
