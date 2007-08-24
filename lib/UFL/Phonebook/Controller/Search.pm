package UFL::Phonebook::Controller::Search;

use strict;
use warnings;
use base qw/Catalyst::Controller/;
use URI;

__PACKAGE__->mk_accessors(qw/sources default_source/);

=head1 NAME

UFL::Phonebook::Controller::Search - Search controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for handling the multisearch form.

=head1 METHODS

=head2 search

Search the specified source.

=cut

sub search : Path('') {
    my ($self, $c) = @_;

    # Check for 'person' for old UFL::Phonebook search
    my $query  = $c->req->param('query')  || $c->req->param('person');
    my $source = $c->req->param('source') || '';

    $source =~ s/[^a-z]//g;
    my $source_info = $self->sources->{$source} || $self->sources->{$self->default_source};
    $c->detach('/default') unless $source_info;

    my $url = $source_info->{url} =~ /^http:/
        ? URI->new($source_info->{url})
        : $c->uri_for($source_info->{url});
    $url->query_form($source_info->{param} => $query);

    $c->log->debug("Search URL: [$url]");
    $c->res->redirect($url);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
