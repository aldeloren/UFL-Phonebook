package Uf::Webadmin::Phonebook::C::Search;

use strict;
use base 'Catalyst::Base';

=head1 NAME

Uf::Webadmin::Phonebook::C::Search - Search controller component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>

=head1 DESCRIPTION

Handle search requests.

=head1 METHODS

=head2 default

Handle a search request.  If no query is specified, forward back to the home
page.

=cut

sub default : Private {
    my ($self, $c) = @_;

    if ($c->req->params->{query}) {
        $c->forward('search');
    }
    else {
        $c->forward('/home');
    }
}

=head2 search

Perform a search.

=cut

sub search : Private {
    my ($self, $c) = @_;

    $c->res->output($c->req->params->{query});
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
