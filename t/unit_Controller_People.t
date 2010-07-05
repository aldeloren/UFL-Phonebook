use strict;
use warnings;
use Test::More tests => 33;
use UFL::Phonebook::Entry;

use_ok('UFL::Phonebook::Controller::People');

my $QUERY        = 'lastname';
my $CN           = 'Last,First M';
my $UID          = 'firstlast';
my $UFID         = '12345678';
my $ENCODED_UFID = 'WNSNJVNEJ';

my $controller = UFL::Phonebook::Controller::People->new({
    max_permuted_tokens => 10,
    filter_key          => 'uid',
    filter_values       => [ qw/asr dwc/ ],
});
isa_ok($controller, 'UFL::Phonebook::BaseController');
is($controller->max_permuted_tokens, 10, 'set maximum number of tokens allowed in permuting query');

# Test default filter restriction
{
    my $filter = $controller->_get_restriction;
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-)))", 'default restriction filter matches');
}

# Test simple filter generation
{
    my $filter = $controller->filter('cn', '=', $CN);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(cn=$CN)(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter matches');
}

# Test filter generation for query with one word
{
    my $filter = $controller->_parse_query($QUERY);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(cn=*$QUERY*)(sn=*$QUERY*)(uid=$QUERY)(mail=$QUERY\@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for one-word query matches');
}

# Test filter generation for query with two words
{
    my $filter = $controller->_parse_query('First Last');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(&(sn=last*)(givenName=*first*))(cn=*First Last*)(cn=last*, first*)(cn=last*,first*)(mail=firstlast\@*)(mail=first-last\@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for two-word query matches');
}

# Test filter generation for query with two comma-separated words
{
    my $filter = $controller->_parse_query('Last, First');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(&(sn=last*)(givenName=*first*))(cn=*Last, First*)(cn=last*, first*)(cn=last*,first*)(mail=firstlast\@*)(mail=first-last\@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for two-word query with comma matches');
}

# Test filter generation for query with three words
{
    my $filter = $controller->_parse_query('First M. Last');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(sn=First M. Last*)(cn=*First M. Last*)(&(sn=m last*)(givenName=*first*))(cn=m last*, first*)(cn=m last*,first*)(mail=firstmlast\@*)(mail=first-mlast\@*)(&(sn=last*)(givenName=*first m*))(cn=last*, first m*)(cn=last*,first m*)(mail=firstmlast@*)(mail=firstm-last@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for three-word query matches');
}

# Test filter generation for query with three comma-separated words
{
    my $filter = $controller->_parse_query('Last,First M.');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(|(sn=Last,First M.*)(cn=*Last,First M.*)(&(sn=m last*)(givenName=*first*))(cn=m last*, first*)(cn=m last*,first*)(mail=firstmlast\@*)(mail=first-mlast\@*)(&(sn=last*)(givenName=*first m*))(cn=last*, first m*)(cn=last*,first m*)(mail=firstmlast@*)(mail=firstm-last@*))(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for three-word query matches');
}

# Test filter generation for old show.cgi-style UFID query
{
    my $filter = $controller->_get_show_cgi_filter($ENCODED_UFID);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(uflEduUniversityId=$UFID)(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for show.cgi UFID query matches');
}

# Test filter generation for old show.cgi-style uid query
{
    my $filter = $controller->_get_show_cgi_filter($UID);
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(uid=$UID)(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for show.cgi uid query matches');
}

# Test filter generation for old show.cgi-style name query
{
    my $filter = $controller->_get_show_cgi_filter('AT+A.+TESTER');
    isa_ok($filter, 'UFL::Phonebook::Filter::Abstract');
    is($filter->as_string, "(&(cn=TESTER,AT A.*)(&(!(eduPersonPrimaryAffiliation=affiliate))(!(eduPersonPrimaryAffiliation=-*-))))", 'filter for show.cgi name query matches');
}

# Test filter generation for old show.cgi-style name query
{
    eval { my $filter = $controller->_get_show_cgi_filter('something invalid') };
    ok($@, 'invalid show.cgi query threw an error');
}

# Test filtering
{
    is($controller->filter_key, 'uid', 'set filter key');
    is(scalar @{ $controller->filter_values }, 2, 'set two filter values');
    is_deeply($controller->filter_values, [ qw/asr dwc/ ], 'set correct filter values');
    ok($controller->_filter_values_hash->{asr}, 'filter values hash contains "asr"');
    ok($controller->_filter_values_hash->{dwc}, 'filter values hash contains "dwc"');

    my $asr_entry = UFL::Phonebook::Entry->new(
        'uflEduUniversityId=11111111,ou=People,dc=ufl,dc=edu',
        uflEduUniversityId => '11111111',
        uid                => 'asr',
    );

    my $dwc_entry = UFL::Phonebook::Entry->new(
        'uflEduUniversityId=22222222,ou=People,dc=ufl,dc=edu',
        uflEduUniversityId => '22222222',
        uid                => 'dwc',
    );

    my $foo_entry = UFL::Phonebook::Entry->new(
        'uflEduUniversityId=33333333,ou=People,dc=ufl,dc=edu',
        uflEduUniversityId => '33333333',
        uid                => 'foo',
    );

    ok($controller->hide_entry($asr_entry), 'hiding "asr"');
    ok($controller->hide_entry($dwc_entry), 'hiding "dwc"');
    ok(! $controller->hide_entry($foo_entry), 'not hiding "foo"');

    my @filtered_entries = $controller->filter_entries($asr_entry, $dwc_entry, $foo_entry);
    is(scalar @filtered_entries, 1, 'filtered from three entries to one');
}
