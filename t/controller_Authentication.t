use strict;
use warnings;
use Test::More tests => 19;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->allow_external(1);

use_ok('UFL::Phonebook::Controller::Authentication');

my $controller    = UFL::Phonebook->controller('Authentication');
my $auth_config   = UFL::Phonebook->config->{authentication};
my $can_test_auth = exists $auth_config->{realms};

# Test redirection to protected location
{
    my $authenticated_uri = '/private/';

    $controller->use_login_form(0);
    $controller->use_environment(0);
    $controller->authenticated_uri($authenticated_uri);

    $mech->get('/login');
    my $response = $mech->response->previous;
    ok($response, 'found response chain');
    ok($response->is_redirect, 'previous response was a redirect');
    is($response->header('Location'), "http://localhost$authenticated_uri", 'response redirected to correct place');

    $mech->get_ok('/logout', 'request to logout');
}

# Test login form
SKIP: {
    $controller->use_login_form(1);
    $controller->use_environment(0);
    $controller->authenticated_uri(undef);
    $controller->logout_uri(undef);

    $mech->get_ok('/login', 'request for login page');
    $mech->title_like(qr/Login/i, 'looks like a login page');
    $mech->content_like(qr/Username/i, 'appears to contain a username field');
    $mech->content_like(qr/Password/i, 'appears to contain a password field');

    skip 'Need at least one configured realm', 3 unless $can_test_auth;
    $mech->submit_form(with_fields => {
        username => 'dwc',
        password => 'dwc',
    });
    ok($mech->success, 'submitted form');
    $mech->content_like(qr|Logged in as <a href="http://localhost/people/[A-Z]{8,9}/" class="user">dwc</a>|, 'looks like we logged in');

    $mech->get_ok('/logout', 'request to logout');
}

# Test login via environment
SKIP: {
    skip 'Need at least one configured realm', 7 unless $can_test_auth;

    my $default_realm = $auth_config->{default_realm};
    my $realm_config  = $auth_config->{realms}->{$default_realm};
    skip 'Default realm must use AnyUser store', 3
        unless $realm_config->{store}->{class} =~ /AnyUser$/;

    my $logout_uri = 'http://login.gatorlink.ufl.edu/quit.cgi';

    $controller->use_login_form(0);
    $controller->use_environment(1);
    $controller->authenticated_uri(undef);
    $controller->logout_uri($logout_uri);

    # Without REMOTE_USER
    eval { $mech->get('/login', 'request for login page') };
    is($mech->status, 500, 'request failed');

    # With REMOTE_USER
    local $ENV{REMOTE_USER} = 'dwc';
    $mech->get_ok('/login', 'request for login page');
    $mech->content_like(qr|Logged in as <a href="http://localhost/people/[A-Z]{8,9}/" class="user">dwc</a>|, 'looks like we logged in');

    $mech->get_ok('/logout', 'request to logout');
    my $response = $mech->response->previous;
    ok($response, 'found response chain');
    ok($response->is_redirect, 'previous response was a redirect');
    is($response->header('Location'), $logout_uri, 'response redirected to correct place');
}
