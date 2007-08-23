use strict;
use warnings;
use Test::More tests => 19;

use Test::WWW::Mechanize::Catalyst 'UFL::Phonebook';
my $mech = Test::WWW::Mechanize::Catalyst->new;

use_ok('UFL::Phonebook::Controller::Authentication');

my $controller = UFL::Phonebook->controller('Authentication');

# Test redirection to protected location
{
    my $redirect_to = 'http://localhost/private/';

    $controller->redirect_to($redirect_to);
    $controller->use_login_form(0);
    $controller->username_env_key(undef);

    $mech->get('/login');
    my $response = $mech->response->previous;
    ok($response, 'found response chain');
    ok($response->is_redirect, 'previous response was a redirect');
    is($response->header('Location'), $redirect_to, 'response redirected to correct place');

    $mech->get_ok('/logout', 'request to logout');
}

# Test login form
{
    $controller->redirect_to(undef);
    $controller->use_login_form(1);
    $controller->username_env_key(undef);
    $controller->logout_uri(undef);

    $mech->get_ok('/login', 'request for login page');
    $mech->title_like(qr/Login/i, 'looks like a login page');
    $mech->content_like(qr/Username/i, 'appears to contain a username field');
    $mech->content_like(qr/Password/i, 'appears to contain a password field');
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
    my $default_realm = UFL::Phonebook->config->{authentication}->{default_realm};
    my $realm_config  = UFL::Phonebook->config->{authentication}->{realms}->{$default_realm};
    skip 'Default realm must use AnyUser store', 3
        unless $realm_config->{store}->{class} =~ /AnyUser$/;

    my $username_env_key = 'REMOTE_USER';
    my $logout_uri       = 'http://login.gatorlink.ufl.edu/quit.cgi';

    $controller->redirect_to(undef);
    $controller->use_login_form(0);
    $controller->username_env_key($username_env_key);
    $controller->logout_uri($logout_uri);

    # Without REMOTE_USER
    eval { $mech->get('/login', 'request for login page') };
    is($mech->status, 500, 'request failed');

    # With REMOTE_USER
    local $ENV{$username_env_key} = 'dwc';
    $mech->get_ok('/login', 'request for login page');
    $mech->content_like(qr|Logged in as <a href="http://localhost/people/[A-Z]{8,9}/" class="user">dwc</a>|, 'looks like we logged in');

    $mech->get_ok('/logout', 'request to logout');
    my $response = $mech->response->previous;
    ok($response, 'found response chain');
    ok($response->is_redirect, 'previous response was a redirect');
    is($response->header('Location'), $logout_uri, 'response redirected to correct place');
}
