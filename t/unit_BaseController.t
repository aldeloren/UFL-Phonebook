use strict;
use warnings;
use Test::More tests => 4;
use Test::MockObject;

use_ok('UFL::Phonebook::BaseController');

UFL::Phonebook::BaseController->config(
    namespace  => 'basecontroller',
    model_name => 'Test',
);

# Mock Catalyst object for controller construction and namespace use
my $c = Test::MockObject->new;
$c->set_always('config', {});
$c->set_always('model', 'Test');

my $controller = UFL::Phonebook::BaseController->new($c);
isa_ok($controller, 'Catalyst::Controller');

{
    $controller->model_name('Test');
    my $model = $controller->model($c);
    ok($model, 'got a model back');
}

{
    my $template = $controller->template('test.tt');
    is($template, 'basecontroller/test.tt', 'template path is correct');
}
