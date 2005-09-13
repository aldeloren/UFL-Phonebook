package Uf::Webadmin::Phonebook::C::People;

use strict;
use warnings;
use base 'Catalyst::Base';
use Net::LDAP::Constant;
use Net::LDAP::Filter::Abstract;
use Uf::Webadmin::Phonebook::Constants;
use Uf::Webadmin::Phonebook::Entry;

=head1 NAME

Uf::Webadmin::Phonebook::C::People - Catalyst component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding people.

=head1 METHODS

=head2 default

Display the search form.

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_HOME;
}

=head2 search

Search the directory for people.

=cut

# TODO: Cleanup
sub search : Local {
    my ($self, $c) = @_;

    my $query = $c->req->param('query');
    my $sort  = $c->req->param('sort') || 'cn';

    my $filter = $self->_parseQuery($query);
    my $string = $filter->as_string;

    $c->log->debug("Query: $query");
    $c->log->debug("Filter: $string");

    my $entries;
    eval {
        $entries = $c->comp('M::People')->search($string);

        $c->log->debug("sizelimit: " . LDAP_SIZELIMIT_EXCEEDED);
        my $code = $c->comp('M::People')->code;
        $c->stash->{sizelimit_exceeded} = ($code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED);
        $c->stash->{timelimit_exceeded} = ($code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED);
    };
    if ($@) {
        $c->error($@);
    }

    if ($entries and scalar @{ $entries }) {
        my @results =
            sort { $a->$sort cmp $b->$sort }
            map { Uf::Webadmin::Phonebook::Entry->new($_) }
            @{ $entries };

        if (scalar @results == 1) {
            my $ufid = Uf::Webadmin::Phonebook::Utilities::encodeUfid($results[0]->uflEduUniversityId);
            $c->res->redirect("$ufid/");
        }
        else {
            $c->stash->{results}  = \@results;
            $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_RESULTS;
        }
    }
    else {
        $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_NO_RESULTS;
    }
}

=head2 show

Display a single person.

=cut

sub show : Regex('people/([A-Za-z0-9]{8,9})/?$') {
    my ($self, $c) = @_;

    $c->forward('single');
}

=head2 full

Display details for a single person.

=cut

sub full : Regex('people/([A-Za-z0-9]{8,9})/full/?$') {
    my ($self, $c) = @_;

    $c->forward('single', [ $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_FULL ]);
}

=head2 single

Display a single person. Optionally, you can specify a template with
which to display the person.

=cut

sub single : Private {
    my ($self, $c, $template) = @_;

    $template ||= $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_SHOW;

    my $ufid = Uf::Webadmin::Phonebook::Utilities::decodeUfid($c->req->snippets->[0]);
    $c->log->debug("UFID: $ufid");

    eval {
        my $entries = $c->comp('M::People')->search("uflEduUniversityId=$ufid");
        if (scalar @{ $entries }) {
            $c->stash->{person}   = Uf::Webadmin::Phonebook::Entry->new($entries->[0]);
            $c->stash->{template} = $template;
        }
        else {
            $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_NO_RESULTS;
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head2 _parseQuery

Parse a query into an LDAP filter.

=cut

sub _parseQuery {
    my ($self, $query) = @_;

    my @tokens = $self->_tokenizeQuery($query);

    my $filter = Net::LDAP::Filter::Abstract->new('|');
    if ($query =~ /(.*)\@/) {
        # Email address
        my $uid   = $1;
        my $email = $tokens[0];

        $filter->add('uid',  '=', $uid);
        $filter->add('mail', '=', $email);
        $filter->add('mail', '=', qq[$uid@*]);
    }
#    elsif ($query =~ /(\d{3})?(\d{2}?\d)(\d{4})/) {
#        # TODO: Phone number
#        my $areaCode = $1;
#        my $exchange = $2;
#        my $lastFour = $3;
#
#        my $phone = "+1 $areaCode $exchange$lastFour";
#
#        $filter->add('homePhone',       '=', $phone);
#        $filter->add('telephoneNumber', '=', $phone);
#    }
    elsif (scalar @tokens == 1) {
        # One token: last name or username
        my $name = $tokens[0];

        $filter->add('cn',    '=', qq[$name,*]);
        $filter->add('sn',    '=', qq[$name*]);
        $filter->add('uid',   '=', $name);
        $filter->add('mail',  '=', qq[$name@*]);
        # TODO: Searching title is very slow
#        $filter->add('title', '=', qq[$name*]);
    }
    else {
        # Two or more tokens: first and last name
        my $first = $tokens[0];
        my $last  = $tokens[1];
        ($first, $last) = ($last, $first) if $query =~ /,/;

        $filter->add('cn',    '=', qq[$last,$first*]);
        $filter->add('mail',  '=', qq[$last@*]);
        $filter->add('mail',  '=', qq[$first$last@*]);
        $filter->add('mail',  '=', qq[$first-$last@*]);
        # TODO: Searching title is very slow
#        $filter->add('title', '=', qq[$query*]);
    }

    return Net::LDAP::Filter::Abstract->new('&')
        ->add($filter)
        ->add($self->_getRestriction);
}

=head2 _tokenizeQuery

Split a query into tokens, which can then be used to form LDAP
filters.

=cut

# TODO: Refactor
sub _tokenizeQuery {
    my ($self, $query) = @_;

    # Strip invalid characters
    $query =~ s/[^a-z0-9 .,\-_\'\@]//gi;

    my @tokens;
    if ($query =~ /,/) {
        @tokens = split /,\s*/, lc($query);
    }
    else {
        @tokens = split /\s+/, lc($query);
    }

    return @tokens;
}

=head2 _getRestriction

Build the default filter for restricting people searches to current
members of the community.

=cut

sub _getRestriction {
    my ($self) = @_;

    my $filter = Net::LDAP::Filter::Abstract->new('&');
    $filter->add(Net::LDAP::Filter::Abstract->new('!')->add(qw/eduPersonPrimaryAffiliation = affiliate/));
    $filter->add(Net::LDAP::Filter::Abstract->new('!')->add(qw/eduPersonPrimaryAffiliation = -*-/));

    return $filter;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
