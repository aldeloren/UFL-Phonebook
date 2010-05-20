#!perl

use strict;
use warnings;
use Test::More tests => 4;
use Test::MockObject;

use FindBin;
use lib "$FindBin::Bin/lib";
use UFL::Phonebook::TestEnv;

BEGIN { use_ok 'UFL::Phonebook::Authentication::Store' }

my $c = Test::MockObject->new;
my $engine = Test::MockObject->new;

$engine->mock('env', sub { UFL::Phonebook::TestEnv->get });
$c->mock('engine', sub { $engine });

my $store = UFL::Phonebook::Authentication::Store->new({}, $c);
isa_ok($store, 'UFL::Phonebook::Authentication::Store');

my $user = $store->find_user({ username => 'dwc@ufl.edu' }, $c);
isa_ok($user, 'UFL::Phonebook::Authentication::User');
is($user->username, 'dwc@ufl.edu', 'store returned a user with the correct username');
