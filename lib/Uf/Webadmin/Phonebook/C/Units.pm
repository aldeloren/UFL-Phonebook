package Uf::Webadmin::Phonebook::C::Units;

use strict;
use warnings;
use base 'Catalyst::Base';
use Net::LDAP::Constant;
use Uf::Webadmin::Phonebook::Constants;
use Uf::Webadmin::Phonebook::Entry;
use Uf::Webadmin::Phonebook::Filter::Abstract;
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

If a UFID is specified, display the specified unit. Otherwise, display
the units home page.

=cut

sub default : Private {
    # TODO: Remove $junk parameter - possibly fixed in Catalyst trunk?
    my ($self, $c, $junk, $ufid, $full) = @_;

    $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_HOME;

    if ($ufid) {
        $c->forward('single', [ $ufid, $full ]);
    }
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
                $c->stash->{single_result} = 1;
                $c->forward('single', [ $ufid ]);
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

=head2 single

Display a single unit. Optionally, you can specify a template with
which to display the unit.

=cut

sub single : Private {
    my ($self, $c, $ufid, $full) = @_;

    $c->log->debug("UFID: $ufid");

    eval {
        my $entries = $c->comp('M::Organizations')->search("uflEduUniversityId=$ufid");
        if (scalar @{ $entries }) {
            $c->stash->{unit}     = Uf::Webadmin::Phonebook::Entry->new($entries->[0]);
            $c->stash->{template} = (
                $full
                ? $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_FULL
                : $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_SHOW
            );
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

    my $filter = Uf::Webadmin::Phonebook::Filter::Abstract->new('|');
    if ($query =~ /(.*)\@/) {
        # Email address
        my $mail = $tokens[0];

        $filter->add('mail', '=', $mail);
    }
#    elsif ($query =~ /(\d{3})?.?((:?\d{2})?\d).?(\d{4})/) {
#        # TODO: Searching phone numbers seems slow
#        # Phone number
#        my $areaCode = $1;
#        my $exchange = $2;
#        my $lastFour = $3;
#
#        my $phoneNumber = Uf::Webadmin::Phonebook::Utilities::getPhoneNumber($areaCode, $exchange, $lastFour);
#
#        $filter->add('telephoneNumber',          '=', qq[$phoneNumber*]);
#        $filter->add('facsimileTelephoneNumber', '=', qq[$phoneNumber*]);
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
