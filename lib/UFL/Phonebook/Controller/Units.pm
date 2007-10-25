package UFL::Phonebook::Controller::Units;

use strict;
use warnings;
use base qw/UFL::Phonebook::BaseController/;
use UFL::Phonebook::Filter::Abstract;
use UFL::Phonebook::Util;

__PACKAGE__->config(
    model_name => 'Unit',
    sort_field => 'o',
);
__PACKAGE__->mk_accessors(qw/hide/);

=head1 NAME

UFL::Phonebook::Controller::Units - Units controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding units (departments or other
campus organizations).

=head1 METHODS

=head2 single

Display a single unit. By specifying an argument after the PeopleSoft
department ID and providing a corresponding local action, you can
override the display behavior of the unit.

=cut

sub single : PathPart('units') Chained('/') CaptureArgs(1) {
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

    my $mesg  = $self->model($c)->search("uflEduPsDeptId=$psid");
    my $entry = $mesg->shift_entry;
    unless ($entry) {
        # Redirect from the UFID to the PeopleSoft department ID
        $mesg  = $self->model($c)->search("uflEduUniversityId=$psid");
        $entry = $mesg->shift_entry;
        $c->detach('/default') unless $entry;

        $c->res->redirect($c->uri_for($c->action, $entry->uri_args, ''), 301);
        $c->detach;
    }

    $c->stash(entry => $entry);
}

=head2 people

Search for people whose primary organizational affiliation matches the
specified PeopleSoft department ID.

=cut

sub people : PathPart Chained('single') Args(0) {
    my ($self, $c) = @_;

    my $unit = $c->stash->{entry};

    my $filter = $c->controller('People')->filter('departmentNumber', '=', $unit->uflEduPsDeptId);
    $c->log->debug("Filter: $filter");

    my $mesg = $c->model('Person')->search($filter->as_string);
    $c->forward('/people/results', [ $mesg ]);
}

=head2 filter

Return a new L<UFL::Phonebook::Filter::Abstract> used for finding
units.

=cut

sub filter {
    my ($self, @filter) = @_;

    return UFL::Phonebook::Filter::Abstract->new('&')
        ->add(@filter);
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

    return $self->filter($filter);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
