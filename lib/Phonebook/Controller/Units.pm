package Phonebook::Controller::Units;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Net::LDAP::Constant;
use Phonebook::Filter::Abstract;
use Phonebook::Unit;
use Phonebook::Util;

=head1 NAME

Phonebook::Controller::Units - Units controller component

=head1 SYNOPSIS

See L<Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding units (departments or other
campus organizations).

=head1 METHODS

=head2 index

Redirect to the L<Phonebook> home page.

=cut

sub index : Private {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for('/'));
}

=head2 search

Search the directory for units.

=cut

sub search : Local {
    my ($self, $c) = @_;

    my $query = $c->req->param('query');
    $c->detach('index') if not $query
        or $query eq $c->config->{units}->{default};

    my $filter = $self->_parse_query($query);
    my $string = $filter->as_string;

    $c->log->debug("Query: $query");
    $c->log->debug("Filter: $string");

    my $mesg = $c->model('Organization')->search($string);
    $c->forward('results', [ $mesg ]);
}

=head2 results

Display the units from the specified L<Net::LDAP::Message>. If only
one unit is found, display it directly.

=cut

sub results : Private {
    my ($self, $c, $mesg) = @_;

    $c->stash->{sizelimit_exceeded} = ($mesg->code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED);
    $c->stash->{timelimit_exceeded} = ($mesg->code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED);

    my $sort  = $c->req->param('sort') || 'o';
    my @units =
        sort { $a->$sort cmp $b->$sort }
        map  { Phonebook::Unit->new($_) }
        $mesg->entries;

    if (scalar @units == 1) {
        my $ufid = $units[0]->uflEduUniversityId;

        $c->res->cookies->{query} = { value => $c->req->param('query') };
        $c->res->redirect($c->uri_for('/units', $ufid, ''));
    }
    elsif (scalar @units > 0) {
        $c->stash->{units}    = \@units;
        $c->stash->{template} = 'units/results.tt';
    }
    else {
        $c->stash->{template} = 'units/noResults.tt';
    }
}

=head2 single

Display a single unit. By specifying an argument after the UFID and
providing a corresponding local action, you can override the display
behavior of the unit.

=cut

sub single : Path('') {
    my ($self, $c, $ufid, $action) = @_;

    $c->detach('/default') unless $ufid;
    $c->log->debug("UFID: $ufid");

    # Handle redirection when a search query returns only one person
    my $query = $c->req->cookies->{query};
    if ($query and $query->value) {
        $c->stash->{query} = $query->value;
        $c->res->cookies->{query} = { value => '' };

        $c->stash->{single_result} = 1;
    }

    my $mesg = $c->model('Organization')->search("uflEduUniversityId=$ufid");
    my $entry = $mesg->shift_entry;
    $c->detach('/default') unless $entry;

    $c->stash->{unit}     = Phonebook::Unit->new($entry);
    $c->stash->{template} = 'units/show.tt';

    if ($action) {
        $c->detach('/default') unless $self->can($action);
        $c->detach($action);
    }
}

=head2 full

Display the full entry for a single unit.

=cut

sub full : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = 'units/full.tt';
}

=head2 people

Search for people whose primary organizational affiliation matches the
specified UFID.

=cut

sub people : Private {
    my ($self, $c) = @_;

    my $unit = $c->stash->{unit};
    $c->detach('/default') unless $unit;

    my $filter = $c->controller('People')->_get_restriction;
    $filter->add('departmentNumber', '=', $unit->uflEduUniversityId);

    $c->log->debug("Filter: $filter");

    my $mesg = $c->model('Person')->search($filter->as_string);
    $c->forward('/people/results', [ $mesg ]);
}

=head2 _parse_query

Parse a query into an LDAP filter.

=cut

sub _parse_query {
    my ($self, $query) = @_;

    my @tokens = Phonebook::Util::tokenize_query($query);

    my $filter = Phonebook::Filter::Abstract->new('|');
    if ($query =~ /([^@]+)\@/) {
        # Email address
        my $mail = $tokens[0];

        $filter->add('mail', '=', $mail);
    }
#    elsif ($query =~ /(\d{3})?.?((:?\d{2})?\d).?(\d{4})/) {
#        # TODO: Searching phone numbers seems slow
#        # Phone number
#        my $area_code = $1;
#        my $exchange = $2;
#        my $last_four = $3;
#
#        my $phone_number = Phonebook::Util::getPhoneNumber($area_code, $exchange, $last_four);
#
#        $filter->add('telephoneNumber',          '=', qq[$phone_number*]);
#        $filter->add('facsimileTelephoneNumber', '=', qq[$phone_number*]);
#    }
    else {
        # Unit name
        $filter->add('o', '=', qq[*$query*]);
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
