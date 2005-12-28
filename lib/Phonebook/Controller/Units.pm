package Phonebook::Controller::Units;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Net::LDAP::Constant;
use Phonebook::Entry;
use Phonebook::Filter::Abstract;
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

Display the units home page.

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
    my $sort  = $c->req->param('sort') || 'o';
    $c->detach('index') unless $query;

    my $filter = $self->_parse_query($query);
    my $string = $filter->as_string;

    $c->log->debug("Query: $query");
    $c->log->debug("Sort: $sort");
    $c->log->debug("Filter: $string");

    eval {
        my $model   = $c->model('Organization');
        my $entries = $model->search($string);
        my $code    = $model->code;

        if ($entries and scalar @$entries) {
            my @results = sort { $a->$sort cmp $b->$sort } @$entries;

            if (scalar @results == 1) {
                my $ufid = $results[0]->uflEduUniversityId;
                $c->stash->{single_result} = 1;
                $c->forward('single', [ $ufid ]);
            }
            else {
                $c->stash->{sizelimit_exceeded} = ($code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED);
                $c->stash->{timelimit_exceeded} = ($code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED);

                $c->stash->{results}  = \@results;
                $c->stash->{template} = 'units/results.tt';
            }
        }
        else {
            $c->stash->{template} = 'units/noResults.tt';
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head2 single

Display a single unit. By specifying an argument after the UFID and
providing a corresponding local action, you can override the display
behavior of the unit.

=cut

sub single : Path('') {
    my ($self, $c, $ufid, $action) = @_;

    $c->log->debug("UFID: $ufid");

    eval {
        my $entries = $c->model('Organization')->search("uflEduUniversityId=$ufid");
        if ($entries and scalar @$entries) {
            $c->stash->{unit} = $entries->[0];

            if ($action and $self->can($action)) {
                $c->forward($action, [ $ufid ]);
            }
            else {
                $c->stash->{template} = 'units/show.tt';
            }
        }
        else {
            $c->stash->{template} = 'units/noResults.tt';
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head2 full

Display the full entry for a single unit.

=cut

sub full : Private {
    my ($self, $c, $ufid) = @_;

    $c->stash->{template} = 'units/full.tt';
}

=head2 _parse_query

Parse a query into an LDAP filter.

=cut

sub _parse_query {
    my ($self, $query) = @_;

    my @tokens = Phonebook::Util::tokenize_query($query);

    my $filter = Phonebook::Filter::Abstract->new('|');
    if ($query =~ /(.*)\@/) {
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
