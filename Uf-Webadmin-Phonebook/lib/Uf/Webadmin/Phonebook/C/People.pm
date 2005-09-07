package Uf::Webadmin::Phonebook::C::People;

use strict;
use base 'Catalyst::Base';
use Net::LDAP::Filter::Abstract;
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

    $c->forward('/default');
}

=head2 search

Search the directory for people.

=cut

sub search : Local {
    my ($self, $c) = @_;

    eval {
        my $query = $c->request->param('query');
        my $filter = $self->_parseQuery($query);
        my $filterString = $filter->as_string;

        $c->log->debug("Query: $query");
        $c->log->debug("Filter: $filterString");

        my $entries = $c->component('M::People')->search($filterString);
        if ($entries) {
            my @results = sort { $a->{cn} cmp $b->{cn} } map { Uf::Webadmin::Phonebook::Entry->new($_) } @{ $entries };

            $c->stash->{results}  = \@results;
            $c->stash->{template} = 'people/results.tt';
        }
        else {
            $c->stash->{template} = 'people/noResults.tt';
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head2 show

Display a single person.

=cut

sub show : Regex('people/([A-Za-z0-9]{8,9})/?$') {
    my ($self, $c) = @_;

    my $ufid = Uf::Webadmin::Phonebook::Utilities::decodeUfid($c->request->snippets->[0]);
    $c->log->debug("UFID: $ufid");

    $c->stash->{template} = 'people/show.tt';
}

=head2 full

Display the full entry for a specific person.

=cut

sub full : Regex('people/([A-Za-z0-9]{8,9})/full/?$') {
    my ($self, $c) = @_;

    my $ufid = Uf::Webadmin::Phonebook::Utilities::decodeUfid($c->request->snippets->[0]);
    $c->log->debug("UFID: $ufid");

    $c->stash->{template} = 'people/full.tt';
}

=head2 _parseQuery

Parse a query into an LDAP filter.

=cut

sub _parseQuery {
    my ($self, $query) = @_;

    my @tokens = $self->_tokenizeQuery($query);

    my $filter = Net::LDAP::Filter::Abstract->new('|');
    if ($query =~ /(.*)\@/) {     # Email address
        my $uid   = $1;
        my $email = $tokens[0];

        $filter->add('uid',  '=', $uid);
        $filter->add('mail', '=', $email);
        $filter->add('mail', '=', qq[$uid@*]);
    }
    elsif (scalar @tokens == 1) {  # One token: last name or username
        my $name = $tokens[0];

        $filter->add('cn',   '=', qq[$name,*]);
        $filter->add('sn',   '=', qq[$name*]);
        $filter->add('uid',  '=', $name);
        $filter->add('mail', '=', qq[$name@*]);
    }
    else {                         # Two or more tokens: first and last name
        my $first = $tokens[0];
        my $last  = $tokens[1];
        ($first, $last) = ($last, $first) if $query =~ /,/;

        $filter->add('cn',   '=', qq[$last,$first]);
        $filter->add('sn',   '=', qq[$last*]);
        $filter->add('mail', '=', qq[$last@*]);
        $filter->add('mail', '=', qq[$first$last@*]);
        $filter->add('mail', '=', qq[$first-$last@*]);
    }

    return Net::LDAP::Filter::Abstract->new('&')
        ->add($filter)
        ->add($self->_getRestriction);
}

=head2 _tokenizeQuery

Split a query into tokens, which can then be used to form LDAP
filters.

=cut

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
