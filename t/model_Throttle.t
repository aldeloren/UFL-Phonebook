#!perl

use strict;
use warnings;
use DateTime;
use Test::More tests => 11;

BEGIN { use_ok('UFL::Phonebook::Model::Throttle') }

my $model = UFL::Phonebook::Model::Throttle->new({
    throttler_options => {
        max_items => 5,
        interval  => 3600,
    },
});

isa_ok($model, 'UFL::Phonebook::Model::Throttle');
isa_ok($model, 'Catalyst::Model');

ok($model->allow('127.0.0.1'), 'allowing localhost on first try');
ok($model->allow('127.0.0.1'), 'allowing localhost on second try');
ok($model->allow('127.0.0.1'), 'allowing localhost on third try');
ok($model->allow('127.0.0.1'), 'allowing localhost on fourth try');
ok($model->allow('127.0.0.1'), 'allowing localhost on fifth try');
ok(! $model->allow('127.0.0.1'), 'allowing localhost on sixth try');

ok($model->allow('192.168.1.1'), 'allowing a different IP address');

$model->remove('127.0.0.1');
ok($model->allow('127.0.0.1'), 'removed localhost to allow subsequent requests');
