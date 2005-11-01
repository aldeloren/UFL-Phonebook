package Uf::Webadmin::Phonebook::C::People;

use strict;
use warnings;
use base 'Catalyst::Base';
use Net::LDAP::Constant;
use Uf::Webadmin::Phonebook::Constants;
use Uf::Webadmin::Phonebook::Entry;
use Uf::Webadmin::Phonebook::Filter::Abstract;
use Uf::Webadmin::Phonebook::Utilities;

=head1 NAME

Uf::Webadmin::Phonebook::C::People - Catalyst component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding people.

=head1 METHODS

=head2 default

If a UFID is specified, display the specified person. Otherwise,
display the people home page.

=cut

sub default : Private {
    # TODO: Remove $junk parameter - possibly fixed in Catalyst trunk?
    my ($self, $c, $junk, $ufid, @args) = @_;

    if ($ufid) {
        $c->forward('single', [ $ufid, @args ]);
    }
    else {
        $c->res->redirect('/');
    }
}

=head2 search

Search the directory for people.

=cut

sub search : Local {
    my ($self, $c) = @_;

    my $query = $c->req->param('query');
    my $sort  = $c->req->param('sort') || 'cn';
    $c->detach('default') unless $query;

    my $filter = $self->_parse_query($query);
    my $string = $filter->as_string;

    $c->log->debug("Query: $query");
    $c->log->debug("Sort: $sort");
    $c->log->debug("Filter: $string");

    eval {
        my $people  = $c->comp('M::People');
        my $entries = $people->search($string);
        my $code    = $people->code;

        if ($entries and scalar @$entries) {
            my @results =
                sort { $a->$sort cmp $b->$sort }
                map  { Uf::Webadmin::Phonebook::Entry->new($_) }
                @{ $entries };

            if (scalar @results == 1) {
                my $ufid = Uf::Webadmin::Phonebook::Utilities::encode_ufid($results[0]->uflEduUniversityId);
                $c->stash->{single_result} = 1;
                $c->forward('single', [ $ufid ]);
            }
            else {
                $c->stash->{sizelimit_exceeded} = ($code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED);
                $c->stash->{timelimit_exceeded} = ($code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED);

                $c->stash->{results}  = \@results;
                $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_RESULTS;
            }
        }
        else {
            $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_NO_RESULTS;
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head2 single

Display a single person. By specifying an argument after the UFID and
providing a corresponding local action, you can override the display
behavior of the person.

=cut

sub single : Private {
    my ($self, $c, $ufid, $action) = @_;

    $ufid = Uf::Webadmin::Phonebook::Utilities::decode_ufid($ufid);
    $c->log->debug("UFID: $ufid");

    eval {
        my $entries = $c->comp('M::People')->search("uflEduUniversityId=$ufid");
        if ($entries and scalar @$entries) {
            $c->stash->{person} = Uf::Webadmin::Phonebook::Entry->new($entries->[0]);

            if ($action and $self->can($action)) {
                $c->forward($action, [ $ufid ]);
            }
            else {
                $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_SHOW;
            }
        }
        else {
            $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_NO_RESULTS;
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head2 full

Display the full entry for a single person.

=cut

sub full : Private {
    my ($self, $c, $ufid) = @_;

    $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_FULL;
}

=head2 vcard

Display the vCard for a single person.

=cut

sub vcard : Private {
    my ($self, $c, $ufid) = @_;

    my $filename = ($c->stash->{person}->uid || 'vcard') . '.vcf';
    $c->log->debug("Filename: $filename");

    $c->res->content_type('text/x-vcard');
    $c->res->header('Content-Disposition', "attachment; filename=$filename");
    $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_PEOPLE_VCARD;
}

=head2 _parse_query

Parse a query into an LDAP filter.

=cut

sub _parse_query {
    my ($self, $query) = @_;

    my @tokens = Uf::Webadmin::Phonebook::Utilities::tokenize_query($query);

    my $filter = Uf::Webadmin::Phonebook::Filter::Abstract->new('|');
    if ($query =~ /(.*)\@/) {
        # Email address
        my $uid  = $1;
        my $mail = $tokens[0];

        $filter->add('uid',  '=', $uid);
        $filter->add('mail', '=', $mail);
        $filter->add('mail', '=', qq[$uid@*]);
    }
#    elsif ($query =~ /(\d{3})?.?((:?\d{2})?\d).?(\d{4})/) {
#        # TODO: Searching phone numbers seems slow
#        # Phone number
#        my $area_code = $1;
#        my $exchange = $2;
#        my $last_four = $3;
#
#        my $phone_number = Uf::Webadmin::Phonebook::Utilities::getPhoneNumber($area_code, $exchange, $last_four);
#
#        $filter->add('homePhone',       '=', qq[$phone_number*]);
#        $filter->add('telephoneNumber', '=', qq[$phone_number*]);
#    }
    elsif (scalar @tokens == 1) {
        # One token: last name or username
        my $name = $tokens[0];

        $filter->add('cn',    '=', qq[$name,*]);
        $filter->add('sn',    '=', qq[$name*]);
        $filter->add('uid',   '=', $name);
        $filter->add('mail',  '=', qq[$name@*]);
        # TODO: Searching title seems slow
#        $filter->add('title', '=', qq[$name*]);
    }
    else {
        # Two or more tokens: first and last name
        my $first = $tokens[0];
        my $last  = $tokens[1];
        ($first, $last) = ($last, $first) if $query =~ /,/;

        $filter->add('cn',    '=', qq[$last,$first*]);
#        $filter->add('mail',  '=', qq[$last@*]);
        $filter->add('mail',  '=', qq[$first$last@*]);
        $filter->add('mail',  '=', qq[$first-$last@*]);
        # TODO: Searching title seems slow
#        $filter->add('title', '=', qq[$query*]);
    }

    return Uf::Webadmin::Phonebook::Filter::Abstract->new('&')
        ->add($filter)
        ->add($self->_get_restriction);
}

=head2 _get_restriction

Build the default filter for restricting people searches to current
members of the community.

=cut

sub _get_restriction {
    my ($self) = @_;

    my $filter = Uf::Webadmin::Phonebook::Filter::Abstract->new('&');
    $filter->add(Uf::Webadmin::Phonebook::Filter::Abstract->new('!')->add(qw/eduPersonPrimaryAffiliation = affiliate/));
    $filter->add(Uf::Webadmin::Phonebook::Filter::Abstract->new('!')->add(qw/eduPersonPrimaryAffiliation = -*-/));

    return $filter;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
