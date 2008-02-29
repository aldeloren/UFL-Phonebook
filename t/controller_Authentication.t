use strict;
use warnings;
use Test::More tests => 34;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->allow_external(1);

use_ok('UFL::Phonebook::Controller::Authentication');

my $root_controller = UFL::Phonebook->controller('Root');
my $auth_controller = UFL::Phonebook->controller('Authentication');
my $auth_config     = UFL::Phonebook->config->{authentication};
my $can_test_auth   = exists $auth_config->{realms};

# Test redirection to protected location
{
    my $authenticated_uri = '/private/';

    $auth_controller->use_login_form(0);
    $auth_controller->use_environment(0);
    $auth_controller->authenticated_uri($authenticated_uri);
    $auth_controller->logout_uri(undef);

    ok(! $auth_controller->auto_login, 'controller does not automatically authenticate users');

    $mech->get_ok('http://localhost/', 'starting at the home page');

    $mech->get('http://localhost/login');
    my $response = $mech->response->previous;
    ok($response, 'found response chain');
    ok($response->is_redirect, 'previous response was a redirect');
    is($response->header('Location'), "http://localhost$authenticated_uri", 'response redirected to correct place');

    $mech->get_ok('http://localhost/logout', 'request to logout');
}

# Test login form
SKIP: {
    $auth_controller->use_login_form(1);
    $auth_controller->use_environment(0);
    $auth_controller->authenticated_uri(undef);
    $auth_controller->logout_uri(undef);

    ok(! $auth_controller->auto_login, 'controller does not automatically authenticate users');

    $mech->get_ok('http://localhost/', 'starting at the home page');

    $mech->get_ok('http://localhost/login', 'request for login page');
    $mech->title_like(qr/Login/i, 'looks like a login page');
    $mech->content_like(qr/Username/i, 'appears to contain a username field');
    $mech->content_like(qr/Password/i, 'appears to contain a password field');

    skip 'need at least one configured realm', 3 unless $can_test_auth;
    $mech->submit_form(with_fields => {
        username => 'dwc',
        password => 'dwc',
    });
    ok($mech->success, 'submitted form');
    $mech->content_like(qr|Logged in as <a href[^>]+>dwc</a>|, 'looks like we logged in');

    $mech->get_ok('http://localhost/logout', 'request to logout');
}

# Test login via environment
SKIP: {
    skip 'need at least one configured realm', 7 unless $can_test_auth;

    my $logout_uri = 'http://login.gatorlink.ufl.edu/quit.cgi';

    $auth_controller->use_login_form(0);
    $auth_controller->use_environment(1);
    $auth_controller->authenticated_uri(undef);
    $auth_controller->logout_uri($logout_uri);

    ok($auth_controller->auto_login, 'controller automatically authenticates users');

    # Without REMOTE_USER
    eval { $mech->get('http://localhost/', 'starting at the home page') };
    is($mech->status, 500, 'request failed without username');

    # With REMOTE_USER
    local $ENV{REMOTE_USER} = 'dwc';
    $mech->get_ok('http://localhost/', 'starting at the home page');
    $mech->content_like(qr|Logged in as <a href[^>]+>dwc</a>|, 'looks like we logged in');

    $mech->get_ok('http://localhost/logout', 'request to logout');
    my $response = $mech->response->previous;
    ok($response, 'found response chain');
    ok($response->is_redirect, 'previous response was a redirect');
    is($response->header('Location'), $logout_uri, 'response redirected to correct place');
}

# Test redirect with previous referer
SKIP: {
    skip 'need at least one configured realm', 5 unless $can_test_auth;

    # Start at public instance
    $auth_controller->use_login_form(0);
    $auth_controller->use_environment(0);
    $auth_controller->authenticated_uri('/private/');
    $auth_controller->logout_uri(undef);

    ok(! $auth_controller->auto_login, 'controller does not automatically authenticate users');

    $mech->get_ok('http://localhost/affiliations/', 'viewed affiliations page on public instance');
    $mech->title_like(qr/Affiliations/i, 'looks like we got the affiliations page');

    # Simulate switch to private instance
    $mech->get('http://localhost/login');

    $auth_controller->use_login_form(0);
    $auth_controller->use_environment(1);
    $auth_controller->authenticated_uri(undef);
    $auth_controller->logout_uri(undef);

    ok($auth_controller->auto_login, 'controller automatically authenticates users');

    local $ENV{REMOTE_USER} = 'dwc';
    $mech->get_ok('http://localhost/', 'starting at the home page');
    $mech->title_like(qr/Affiliations/i, 'returned to affiliations page after public-private switch');

    $mech->get_ok('http://localhost/logout', 'request to logout');
}

# Test direct private link
SKIP: {
    skip 'need at least one configured realm', 2 unless $can_test_auth;

    $auth_controller->use_login_form(0);
    $auth_controller->use_environment(1);
    $auth_controller->authenticated_uri(undef);
    $auth_controller->logout_uri(undef);

    ok($auth_controller->auto_login, 'controller automatically authenticates users');

    local $ENV{REMOTE_USER} = 'dwc';
    $mech->get_ok("http://localhost/people/WHHVHEWHV/", 'automatically redirected to private page on direct request');
    $mech->content_like(qr/Westermann-Clark/i, 'direct link to private page landed in the right place');
}
