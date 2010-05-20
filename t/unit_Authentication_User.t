#!perl

use strict;
use warnings;
use Test::More tests => 15;
use Test::MockObject;

use FindBin;
use lib "$FindBin::Bin/lib";
use UFL::Phonebook::TestEnv;

BEGIN { use_ok 'UFL::Phonebook::Authentication::User' }

# User without a common name
{
    my $user = UFL::Phonebook::Authentication::User->new({
        username => 'dwc@ufl.edu',
        env => UFL::Phonebook::TestEnv->get,
    });

    isa_ok($user, 'UFL::Phonebook::Authentication::User');
    is($user->username, 'dwc@ufl.edu', 'username is correct');
    is($user->id, 'dwc@ufl.edu', 'id accessor returns username');
    is($user->ldap_username, 'dwc', 'LDAP username is correct');
    is($user->display_name, 'dwc@ufl.edu', 'Display name is correct');
    is($user->primary_affiliation, 'staff', 'Primary affiliation is correct');
    is_deeply($user->uri_args, [ qw/WHHVHEWHV/ ], 'URL path arguments are correct');
}

# User with a common name
{
    my $user = UFL::Phonebook::Authentication::User->new({
        username => 'dwc@ufl.edu',
        env => UFL::Phonebook::TestEnv->get(cn => 'Daniel Westermann-Clark'),
    });

    isa_ok($user, 'UFL::Phonebook::Authentication::User');
    is($user->username, 'dwc@ufl.edu', 'username is correct');
    is($user->id, 'dwc@ufl.edu', 'id accessor returns username');
    is($user->ldap_username, 'dwc', 'LDAP username is correct');
    is($user->display_name, 'Daniel Westermann-Clark', 'Display name is correct');
    is($user->primary_affiliation, 'staff', 'Primary affiliation is correct');
    is_deeply($user->uri_args, [ qw/WHHVHEWHV/ ], 'URL path arguments are correct');
}
