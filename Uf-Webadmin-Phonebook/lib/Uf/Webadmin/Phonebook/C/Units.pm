package Uf::Webadmin::Phonebook::C::Units;

use strict;
use warnings;
use base 'Catalyst::Base';
use Uf::Webadmin::Phonebook::Constants;
use Uf::Webadmin::Phonebook::Entry;
use Uf::Webadmin::Phonebook::Utilities;

=head1 NAME

Uf::Webadmin::Phonebook::C::Units - Catalyst component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding units (departments or other
campus organizations).

=head1 METHODS

=head2 default

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_HOME;
}

=head2 search

Search the directory for units.

=cut

sub search : Local {
    my ($self, $c) = @_;

    my $query = $c->req->param('query');
    my $sort  = $c->req->param('sort') || 'o';

    my $filter = $self->_parseQuery($query);
    my $string = $filter->as_string;

    $c->log->debug("Query: $query");
    $c->log->debug("Sort: $sort");
    $c->log->debug("Filter: $string");

    eval {
        my $entries = $c->comp('M::Organizations')->search($string);
        my $code    = $c->comp('M::Organizations')->code;

        if ($entries and scalar @{ $entries }) {
            my @results =
                sort { $a->$sort cmp $b->$sort }
                map { Uf::Webadmin::Phonebook::Entry->new($_) }
                @{ $entries };

            if (scalar @results == 1) {
                my $ufid = Uf::Webadmin::Phonebook::Utilities::encodeUfid($results[0]->uflEduUniversityId);
                $c->res->redirect("$ufid/");
            }
            else {
                $c->stash->{sizelimit_exceeded} = ($code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED);
                $c->stash->{timelimit_exceeded} = ($code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED);

                $c->stash->{results}  = \@results;
                $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_RESULTS;
            }
        }
        else {
            $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_NO_RESULTS;
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head2 show

Display a single unit.

=cut

sub show : Regex('units/([A-Za-z0-9]{8,9})/?$') {
    my ($self, $c) = @_;

    my $ufid = $c->req->snippets->[0];
    $c->forward('single', [ $ufid ]);
}

=head2 full

Display details for a single unit.

=cut

sub full : Regex('units/([A-Za-z0-9]{8,9})/full/?$') {
    my ($self, $c) = @_;

    my $ufid = $c->req->snippets->[0];
    $c->forward('single', [ $ufid, $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_FULL ]);
}

=head2 single

Display a single unit. Optionally, you can specify a template with
which to display the unit.

=cut

sub single : Private {
    my ($self, $c, $ufid, $template) = @_;

    $c->forward('default') unless $ufid;

    $c->log->debug("UFID: $ufid");
    $template ||= $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_SHOW;

    eval {
        my $entries = $c->comp('M::Organizations')->search("uflEduUniversityId=$ufid");
        if (scalar @{ $entries }) {
            $c->stash->{unit}     = Uf::Webadmin::Phonebook::Entry->new($entries->[0]);
            $c->stash->{template} = $template;
        }
        else {
            $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_NO_RESULTS;
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head2 _parseQuery

Parse a query into an LDAP filter.

=cut

sub _parseQuery {
    my ($self, $query) = @_;

    my @tokens = Uf::Webadmin::Phonebook::Utilities::tokenizeQuery($query);

    my $filter = Net::LDAP::Filter::Abstract->new('|');
    if ($query =~ /(.*)\@/) {
        # Email address
        my $mail = $tokens[0];

        $filter->add('mail', '=', $mail);
    }
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
