use strict;
use warnings;
use Test::More;

plan skip_all => 'set TEST_AUTHOR to enable this test' unless $ENV{TEST_AUTHOR};
plan tests    => 6;

use_ok('UFL::Phonebook::Model::Unit');

my %config = (
    host        => 'misc01.osg.ufl.edu',
    base        => 'ou=Organizations,dc=ufl,dc=edu',
    entry_class => 'UFL::Phonebook::Unit',
);

my $model = UFL::Phonebook::Model::Unit->new({
    %config,
});

isa_ok($model, 'UFL::Phonebook::Model::Unit');
isa_ok($model, 'Catalyst::Model::LDAP');

# Anonymous search for public person
{
    my $conn = $model->ACCEPT_CONTEXT;
    my $mesg = $conn->search('uflEduPsDeptId=02010601');
    is($mesg->count, 1, 'search for unit returned something');

    my $entry = $mesg->entry(0);
    isa_ok($entry, 'UFL::Phonebook::Unit');
    is($entry->uflEduPsDeptId, '02010601', 'uflEduPsDeptId matches');
}
