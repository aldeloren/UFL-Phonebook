package Uf::Webadmin::Phonebook::C::Search;

use strict;
use base 'Catalyst::Base';
use Uf::Webadmin::Phonebook::Utilities;

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
        my $filter = Uf::Webadmin::Phonebook::Utilities::parseQuery($c->req->params->{query});
        $c->log->debug('Query: ' . $c->req->params->{query});
        $c->log->debug('Filter: ' . $filter->as_string);

        my $mesg = $c->comp('Person')->search($filter->as_string);
        if ($mesg->code) {
            die $mesg->error;
        }

        if ($mesg->entries) {
            my @results = sort { $a->{cn} cmp $b->{cn} } $mesg->entries;

            $c->stash->{results}  = \@results;
            $c->stash->{template} = 'results.tt';
        }
        else {
            $c->stash->{template} = 'noResults.tt';
        }
    };
    if ($@) {
        $c->stash->{message} = $@;
        $c->forward('/default');
    }
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
