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

    eval {
        my $filter = $self->_parseQuery($c->req->params->{query});
        $c->log->debug('Query: ' . $c->req->params->{query});
        $c->log->debug('Filter: ' . $filter);

        my $mesg = $c->comp('Person')->search($filter);
        if ($mesg->code) {
            die $mesg->error;
        }

        my @results = sort { $a->{cn} cmp $b->{cn} } map { Uf::Webadmin::Phonebook::Entry->new($_) } $mesg->entries;
        $c->stash->{results}  = \@results;
        $c->stash->{template} = 'results.tt';
    };
    if ($@) {
        $c->stash->{error} = $@;
        $c->forward('/default');
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

        $filter = Uf::Webadmin::Phonebook::Filter->new({
            uid  => $uid,
            mail => $uid . '@*',
            mail => $email,
        });
    }
    elsif (scalar @tokens == 1) {  # One token: last name or username
        $filter = Uf::Webadmin::Phonebook::Filter->new({
            cn   => $tokens[0] . ',*',
            uid  => $tokens[0],
            mail => $tokens[0] . '@*',
        });
    }
    else {                         # Two or more tokens: first and last name
        $filter = Uf::Webadmin::Phonebook::Filter->new({
            cn   => $tokens[1] . ',' . $tokens[0] . '*',
            mail => $tokens[1] . '@*',
        });
    }

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
