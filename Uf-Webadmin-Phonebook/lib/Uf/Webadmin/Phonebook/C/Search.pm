package Uf::Webadmin::Phonebook::C::Search;

use strict;
use base 'Catalyst::Base';
use Uf::Webadmin::Phonebook::Entry;
use Uf::Webadmin::Phonebook::Filter;

=head1 NAME

Uf::Webadmin::Phonebook::C::Search - Search controller component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>

=head1 DESCRIPTION

Handle search requests for the University of Florida Phonebook.

=head1 METHODS

=head2 default

Handle a search request.  If no query is specified, forward back to
the home page.

=cut

sub default : Private {
    my ($self, $c) = @_;

    if ($c->req->params->{query}) {
        $c->forward('search');
    }
    else {
        $c->forward('/default');
    }
}

=head2 search

Perform a search for people.

=cut

sub search : Private {
    my ($self, $c) = @_;

    my $filter = $self->_parseQuery($c->req->params->{query});
    my $mesg = $c->comp('Person')->search($filter);

    if ($mesg->code) {
        $c->stash->{error} = $mesg->error;
        $c->forward('/default');
    }
    else {
        my @results = map { Uf::Webadmin::Phonebook::Entry->new($_) } $mesg->entries;
        $c->stash->{results} = \@results;
        $c->stash->{template} = 'results.tt';
    }
}

=head2 _parseQuery

Parse the specified query into an LDAP filter.

=cut

sub _parseQuery {
    my ($self, $query) = @_;

    # Remove wildcards
    $query =~ tr/\*//d;

    if ($query =~ m/[^a-z0-9 .\-_\'\@]/i) {
        die 'Query contains invalid characters';
    }

    my @tokens = split(/\s+/, lc($query));

    my $filter;
    if ($query =~ m/(.*)\@/) {     # Email address
        my $uid   = $1;
        my $email = shift @tokens;

        $filter = Uf::Webadmin::Phonebook::Filter->new(
            uid  => $uid,
            mail => $email,
        );
    }
    elsif (scalar @tokens == 1) {  # One token: username or last name
        $filter = Uf::Webadmin::Phonebook::Filter->new(
            mail => $tokens[0] . '@*',
            uid  => $tokens[0],
            cn   => $tokens[0] . ',*',
        );
    }
    elsif (scalar @tokens == 2) {  # Two tokens: first and last name
    }
    else {
    }

    # TODO: Add default filter on affiliation

    Uf::Webadmin::Phonebook->log->debug("Query: $query");
    Uf::Webadmin::Phonebook->log->debug('Filter: ' . $filter->toString);

    return $filter->toString;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
