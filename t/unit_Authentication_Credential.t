#!perl

use strict;
use warnings;
use Test::More tests => 6;
use Test::MockObject;
use Catalyst::Authentication::User::Hash;

use FindBin;
use lib "$FindBin::Bin/lib";
use UFL::Phonebook::TestEnv;

my $m;
BEGIN { use_ok($m = 'UFL::Phonebook::Authentication::Credential'); }
can_ok($m, 'authenticate');

my $engine = Test::MockObject->new;

my $log = Test::MockObject->new;
$log->mock('debug', sub { diag $_[1] });

my $c = Test::MockObject->new;
$c->mock('engine', sub { return $engine });
$c->mock('log', sub { return $log });
$c->set_false('debug');

my $realm = Test::MockObject->new;
$realm->mock('find_user', sub { return Catalyst::Authentication::User::Hash->new($_[1]) });

# Test the default configuration
{
    $engine->mock('env', sub { UFL::Phonebook::TestEnv->get });

    my $config = {};
    my $cred = $m->new($config, $c, $realm);

    my $user = $cred->authenticate($c, $realm, { id => 1 });
    is(ref $user, 'Catalyst::Authentication::User::Hash', 'user is an object');  # Use ref check instead of isa_ok because of AUTOLOAD
    is($user->username, 'dwc@ufl.edu', 'user authenticated correctly');
}

# Test a non-default configuration
{
    $engine->mock('env', sub { UFL::Phonebook::TestEnv->get(uid => 'test') });

    my $config = { source => 'uid' };
    my $cred = $m->new($config, $c, $realm);

    my $user = $cred->authenticate($c, $realm, { id => 2 });
    is(ref $user, 'Catalyst::Authentication::User::Hash', 'user is an object');  # Use ref check instead of isa_ok because of AUTOLOAD
    is($user->username, 'test', 'user authenticated correctly');
}
