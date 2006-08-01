use strict;
use warnings;
use Test::More tests => 12;

use Test::WWW::Mechanize::Catalyst 'Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('Phonebook::Controller::Search');

my $QUERY   = 'test';
my %SOURCES = (
    web  => qr/search\.ufl\.edu/i,
    news => qr/news\.ufl\.edu/i,
);

$mech->get_ok('/search', 'request for search page');


$mech->get_ok("/search?query=$QUERY", 'request for search results');
$mech->title_like(qr/$QUERY/i, 'response title looks like search results');

$mech->get_ok("/search?person=$QUERY", 'request for search results by person parameter');
$mech->title_like(qr/$QUERY/i, 'response title looks like search results');

$mech->get_ok("/search?query=$QUERY&source=phonebook", 'request for search results, phonebook source');
$mech->title_like(qr/$QUERY/i, 'response title looks like search results');


foreach my $source (keys %SOURCES) {
    $mech->get("/search?query=$QUERY&source=$source");

    # Test::WWW::Mechanize::Catalyst automatically follows the redirect, but
    # thinks it's local to the Catalyst instance
    my $response = $mech->response->previous;
    is($response->code, 302, "request for '$source' source redirected");
    like($response->header('Location'), $SOURCES{$source}, 'looks like it redirected to the right URL');
}
