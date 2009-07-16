use strict;
use warnings;
use Test::More tests => 10;

use_ok('UFL::Phonebook::Controller::Units');

my $QUERY = 'web admin';
my $O     = 'IT-WEB ADMIN OFFICE';
my $PSID  = '14100100';
my $UFID  = 'EWAAGGF1';

my $controller = UFL::Phonebook::Controller::Units->new;
isa_ok($controller, 'UFL::Phonebook::BaseController');

# Test simple filter generation
{
    my $filter = $controller->filter('o', '=', $O);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(o=$O)", 'filter matches');
}

# Test filter generation for query with one word
{
    my $filter = $controller->_parse_query($QUERY);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(o=*$QUERY*)", 'filter for one-word query matches');
}

# Test filter generation for query with more than one word
{
    my $filter = $controller->_parse_query($O);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(o=*$O*)", 'filter for multi-word query matches');
}

# Test filter generation for query for email address
{
    my $filter = $controller->_parse_query('webmaster@ufl.edu');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(mail=webmaster\@ufl.edu)", 'filter for email address query matches');
}
