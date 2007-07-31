package UFL::Phonebook::Controller::Units;

use strict;
use warnings;
use base qw/Catalyst::Controller/;
use Net::LDAP::Constant;
use UFL::Phonebook::Filter::Abstract;
use UFL::Phonebook::Util;

__PACKAGE__->mk_accessors(qw/default_query hide/);

=head1 NAME

UFL::Phonebook::Controller::Units - Units controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding units (departments or other
campus organizations).

=head1 METHODS

=head2 index

Redirect to the L<UFL::Phonebook> home page.

=cut

sub index : Path('') Args(0) {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for('/'));
}

=head2 search

Search the directory for units.

=cut

sub search : Local Args(0) {
    my ($self, $c) = @_;

    my $query = $c->req->param('query');
    $c->detach('index') if not $query
        or $query eq $self->default_query;

    my $filter = $self->_parse_query($query);

    $c->log->debug("Query: $query");
    $c->log->debug("Filter: $filter");

    my $mesg = $c->model('Unit')->search($filter->as_string);
    $c->forward('results', [ $mesg ]);
}

=head2 results

Display the units from the specified L<Net::LDAP::Message>. If only
one unit is found, display it directly.

=cut

sub results : Private {
    my ($self, $c, $mesg) = @_;

    $c->stash(
        sizelimit_exceeded => ($mesg->code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED),
        timelimit_exceeded => ($mesg->code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED),
    );

    my @units = $mesg->entries;

    if (@units == 1) {
        my $unit = shift @units;
        $c->res->cookies->{query} = { value => $c->req->param('query') || $unit->o };
        $c->res->redirect($c->uri_for($self->action_for('view'), $unit->uri_args, ''));
    }
    elsif (@units) {
        my $sort = $c->req->param('sort') || 'o';
        @units   = sort { $a->$sort cmp $b->$sort } @units;

        $c->stash(
            units    => \@units,
            template => 'units/results.tt',
        );
    }
    else {
        $c->stash(template => 'units/no_results.tt');
    }
}

=head2 unit

Display a single unit. By specifying an argument after the PeopleSoft
department ID and providing a corresponding local action, you can
override the display behavior of the unit.

=cut

sub unit : PathPart('units') Chained('/') CaptureArgs(1) {
    my ($self, $c, $psid) = @_;

    $c->log->debug("PeopleSoft department ID: $psid");

    # Handle redirection when a search query returns only one person
    my $query = $c->req->cookies->{query};
    if ($query and my $value = $query->value) {
        $c->stash(
            query  => $value,
            single => 1,
        );

        $c->res->cookies->{query} = { value => '' };
    }

    my $mesg  = $c->model('Unit')->search("uflEduPsDeptId=$psid");
    my $entry = $mesg->shift_entry;
    unless ($entry) {
        # Redirect from the UFID to the PeopleSoft department ID
        $mesg  = $c->model('Unit')->search("uflEduUniversityId=$psid");
        $entry = $mesg->shift_entry;
        $c->detach('/default') unless $entry;

        $c->res->redirect($c->uri_for($c->action, $entry->uri_args, ''), 301);
        $c->detach;
    }

    $c->stash(unit => $entry);
}

=head2 view

Display the stashed unit.

=cut

sub view : PathPart('') Chained('unit') Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'units/view.tt');
}

=head2 full

Display the full entry for a single unit.

=cut

sub full : PathPart Chained('unit') Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'units/full.tt');
}

=head2 people

Search for people whose primary organizational affiliation matches the
specified PeopleSoft department ID.

=cut

sub people : PathPart Chained('unit') Args(0) {
    my ($self, $c) = @_;

    my $filter = $c->controller('People')->_get_restriction;
    $filter->add('departmentNumber', '=', $c->stash->{unit}->uflEduPsDeptId);

    $c->log->debug("Filter: $filter");

    my $mesg = $c->model('Person')->search($filter->as_string);
    $c->forward('/people/results', [ $mesg ]);
}

=head2 _parse_query

Parse a query into an LDAP filter.

=cut

sub _parse_query {
    my ($self, $query) = @_;

    my @tokens = UFL::Phonebook::Util::tokenize_query($query);

    my $filter = UFL::Phonebook::Filter::Abstract->new('|');
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
#        my $phone_number = UFL::Phonebook::Util::getPhoneNumber($area_code, $exchange, $last_four);
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

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
