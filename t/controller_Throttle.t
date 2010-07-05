#!perl

use strict;
use warnings;
use Data::Throttler;
use DateTime;
use Test::More tests => 24;

use FindBin;
use lib "$FindBin::Bin/lib";
use UFL::Phonebook::TestEnv;

use Test::WWW::Mechanize::Catalyst "UFL::Phonebook";
my $mech = Test::WWW::Mechanize::Catalyst->new;

my $QUERY = 'tester';
my $UFID  = 'TVJVWHJJW';

# Override the default throttler so we can reasonably test
my $throttler = Data::Throttler->new(
   max_items => 5,
   interval  => 3600,
);

UFL::Phonebook->model('Throttle')->_throttler($throttler);

# Do enough searches to reach limit
$mech->get_ok("/people/search?query=$QUERY");
$mech->get_ok("/people/$UFID/");
$mech->get_ok("/people/$UFID/full/");

$mech->get_ok("/people/search?query=$QUERY");
$mech->get_ok("/people/$UFID/");

my $dt = DateTime->now(time_zone => 'local');
my $timestamp = $dt->ymd . 'T' . $dt->strftime('%H:%M');

$mech->get("/people/$UFID/vcard/");
is($mech->status, 503, 'user has been throttled');

# Check that the user was throttled
{
    local %ENV = %{ UFL::Phonebook::TestEnv->get };

    $mech->get_ok('/throttle/');
    $mech->content_like(qr/127.0.0.1/, 'displaying user as throttled');
    $mech->content_like(qr/$timestamp/, 'user was throttled in the last minute');
}

$mech->get("/people/$UFID/vcard/");
is($mech->status, 503, 'user has been throttled');

# Verify the throttle after a subsequent search
{
    local %ENV = %{ UFL::Phonebook::TestEnv->get };

    # Check that the "throttled since" time is still valid
    $mech->get_ok('/throttle/');
    $mech->content_like(qr/127.0.0.1/, 'displaying user as throttled');
    $mech->content_like(qr/$timestamp/, 'user was throttled in the last minute');

    # Reset the throttle
    $mech->form_name('remove');
    $mech->submit_form_ok({}, 'removing user from throttle list');
}

# Verify the user can search after a reset
$mech->get_ok("/people/search?query=$QUERY");
$mech->get_ok("/people/$UFID/");
$mech->get_ok("/people/$UFID/full/");

# Add a specific IP
{
    local %ENV = %{ UFL::Phonebook::TestEnv->get };

    $mech->get_ok('/throttle/');
    $mech->content_unlike(qr/192.168.42.1/, 'not displaying user as throttled');

    # Add user to throttle list
    $mech->form_name('add');
    $mech->field('ip', '127.0.0.1');
    $mech->submit_form_ok({}, 'adding user to throttle list');

    $mech->get_ok('/throttle/');
    $mech->content_like(qr/127.0.0.1/, 'displaying user as throttled');

    # Check that the user is throttled
    $mech->get("/people/$UFID/");
    is($mech->status, 503, 'user has been throttled');

    # Reset the throttle
    $mech->form_name('remove');
    $mech->submit_form_ok({}, 'removing user from throttle list');
}
