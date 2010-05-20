#!perl

use strict;
use warnings;
use Test::More tests => 17;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->allow_external(1);

use_ok('UFL::Phonebook::Controller::Authentication');

my $root_controller = UFL::Phonebook->controller('Root');
my $auth_controller = UFL::Phonebook->controller('Authentication');
my $can_test_auth   = ($ENV{UFL_PHONEBOOK_CONFIG_LOCAL_SUFFIX} and $ENV{UFL_PHONEBOOK_CONFIG_LOCAL_SUFFIX} eq 'private');

# Test redirection to protected location
{
    my $authenticated_uri = 'http://localhost/private/';

    $root_controller->auto_login(0);
    $auth_controller->authenticated_uri($authenticated_uri);
    $auth_controller->logout_uri(undef);

    $mech->get_ok('http://localhost/', 'starting at the home page');

    $mech->get('http://localhost/login');
    my $response = $mech->response->previous;
    ok($response, 'found response chain');
    ok($response->is_redirect, 'previous response was a redirect');
    like($response->header('Location'), qr/\Q$authenticated_uri\E/, 'response redirected to correct place');

    $mech->get_ok('http://localhost/logout', 'request to logout');
}

# Test login via environment
{
    my $logout_uri = 'http://login.gatorlink.ufl.edu/quit.cgi';

    $root_controller->auto_login(1);
    $auth_controller->authenticated_uri(undef);
    $auth_controller->logout_uri($logout_uri);

    # Without environment
    eval { $mech->get('http://localhost/', 'starting at the home page') };
    is($mech->status, 403, 'request forbidden without username');

    # With environment
    local $ENV{REMOTE_USER} = 'dwc@ufl.edu';
    local $ENV{glid} = 'dwc';
    local $ENV{ufid} = '13141570';
    local $ENV{primary_affiliation} = 'staff';

    $mech->get_ok('http://localhost/', 'starting at the home page');
    $mech->content_like(qr|Logged in as <a href[^>]+>dwc\@ufl\.edu</a>|, 'looks like we logged in');

    $mech->get_ok('http://localhost/logout', 'request to logout');
    my $response = $mech->response->previous;
    ok($response, 'found response chain');
    ok($response->is_redirect, 'previous response was a redirect');
    is($response->header('Location'), $logout_uri, 'response redirected to correct place');
}

# Test direct private link
SKIP: {
    skip 'load a configuration using UFL::Phonebook::LDAP::Connection, i.e. UFL_PHONEBOOK_CONFIG_LOCAL_SUFFIX=private', 2 unless $can_test_auth;

    local $ENV{REMOTE_USER} = 'dwc@ufl.edu';
    local $ENV{glid} = 'dwc';
    local $ENV{ufid} = '13141570';
    local $ENV{primary_affiliation} = 'staff';

    $mech->get_ok("http://localhost/people/WHHVHEWHV/", 'automatically sent to private page on direct request');
    $mech->content_like(qr/Westermann-Clark/i, 'private page contains expected information');

    # Clear environment so we aren't automatically logged in again
    local $ENV{REMOTE_USER} = '';
    local $ENV{glid} = '';
    local $ENV{ufid} = '';
    local $ENV{primary_affiliation} = '';

    $mech->get('http://localhost/logout', 'request to logout');
}

# Test hiding of student UFIDs
SKIP: {
    skip 'load a configuration using UFL::Phonebook::LDAP::Connection, i.e. UFL_PHONEBOOK_CONFIG_LOCAL_SUFFIX=private', 2 unless $can_test_auth;

    local $ENV{REMOTE_USER} = 'cr@ufl.edu';
    local $ENV{glid} = 'cr';
    local $ENV{ufid} = '13989739';
    local $ENV{primary_affiliation} = 'student';

    $mech->get_ok("http://localhost/people/WHWEWENSN/full/", 'loaded full LDAP entry page');
    $mech->content_unlike(qr/employeeNumber/i, 'page does not contain the employeeNumber field');

    # Clear environment so we aren't automatically logged in again
    local $ENV{REMOTE_USER} = '';
    $mech->get('http://localhost/logout', 'request to logout');
}
