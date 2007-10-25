use strict;
use warnings;
use Test::More tests => 35;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::Phonebook::Controller::Units');

my $QUERY = 'oaa';
my $O     = 'PV-OAA APPLICATION DEVELOP';
my $PSID  = '02010601';
my $UFID  = 'UETHHG63';

my $controller = UFL::Phonebook::Controller::Units->new;
isa_ok($controller, 'UFL::Phonebook::BaseController');

# Test simple filter generation
{
    my $filter = $controller->filter('o', '=', $O);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(o=$O)", 'filter matches');
}

# Test filter generation for query with one word
{
    my $filter = $controller->_parse_query($QUERY);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(o=*$QUERY*)", 'filter for one-word query matches');
}

# Test filter generation for query with more than one word
{
    my $filter = $controller->_parse_query($O);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(o=*$O*)", 'filter for multi-word query matches');
}

# Test filter generation for query for email address
{
    my $filter = $controller->_parse_query('webmaster@ufl.edu');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(mail=webmaster\@ufl.edu)", 'filter for email address query matches');
}


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
