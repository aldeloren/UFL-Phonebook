package Phonebook::Controller::People;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Net::LDAP::Constant;
use Phonebook::Filter::Abstract;
use Phonebook::Person;
use Phonebook::Util;

=head1 NAME

Phonebook::Controller::People - People controller component

=head1 SYNOPSIS

See L<Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding people.

=head1 METHODS

=head2 default

Handle any actions which did not match, i.e. 404 errors.

=cut

sub default : Private {
    my ($self, $c) = @_;

    # TODO: Better error handling
    $c->forward('/default');
}

=head2 index

Display the people home page.

=cut

sub index : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = 'people/index.tt';
}

=head2 search

Search the directory for people.

=cut

sub search : Local {
    my ($self, $c) = @_;

    my $query = $c->req->param('query');
    $c->detach('index') if not $query
        or $query eq $c->config->{people}->{default};

    my $filter = $self->_parse_query($query);
    my $string = $filter->as_string;

    $c->log->debug("Query: $query");
    $c->log->debug("Filter: $string");

    my $mesg = $c->model('Person')->search($string);
    $c->stash->{mesg} = $mesg;

    $c->forward('results');
}

=head2 unit

Search for people whose primary organizational affiliation matches the
specified UFID.

=cut

sub unit : Local {
    my ($self, $c, $ufid) = @_;

    $c->detach('default') unless $ufid;
    $c->log->debug("UFID: $ufid");

    my $mesg = $c->model('Person')->search("departmentNumber=$ufid");
    $c->stash->{mesg} = $mesg;

    $c->forward('results');
}

=head2 results

Display the people from the LDAP response stored in the stash at key
C<mesg>. If only one person is found, display him or her directly.

=cut

sub results : Private {
    my ($self, $c) = @_;

    if (exists $c->stash->{mesg} and my $mesg = $c->stash->{mesg}) {
        $c->stash->{sizelimit_exceeded} = ($mesg->code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED);
        $c->stash->{timelimit_exceeded} = ($mesg->code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED);

        my $sort = $c->req->param('sort') || 'cn';
        my @people =
            sort { $a->$sort cmp $b->$sort }
            map  { Phonebook::Person->new($_) }
            $mesg->entries;

        if (scalar @people == 1) {
            my $ufid = Phonebook::Util::encode_ufid($people[0]->uflEduUniversityId);
            $c->stash->{single_result} = 1;
            $c->forward('single', [ $ufid ]);
        }
        elsif (scalar @people > 0) {
            $c->stash->{people} = \@people;
            $c->stash->{template} = 'people/results.tt';
        }
        else {
            $c->stash->{template} = 'people/noResults.tt';
        }
    }
    else {
        $c->error('No LDAP response');
    }
}

=head2 single

Display a single person. By specifying an argument after the UFID and
providing a corresponding local action, you can override the display
behavior of the person.

=cut

sub single : Path('') {
    my ($self, $c, $ufid, $action) = @_;

    $c->detach('default') unless $ufid;
    $ufid = Phonebook::Util::decode_ufid($ufid);
    $c->log->debug("UFID: $ufid");

    my $mesg = $c->model('Person')->search("uflEduUniversityId=$ufid");
    if (my $entry = $mesg->shift_entry) {
        $c->stash->{person} = Phonebook::Person->new($entry);

        if ($action and $self->can($action)) {
            $c->forward($action);
        }
        else {
            $c->stash->{template} = 'people/show.tt';
        }
    }
    else {
        $c->stash->{template} = 'people/noResults.tt';
    }
}

=head2 full

Display the full entry for a single person.

=cut

sub full : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = 'people/full.tt';
}

=head2 vcard

Display the vCard for a single person.

=cut

sub vcard : Private {
    my ($self, $c) = @_;

    my $filename = ($c->stash->{person}->uid || 'vcard') . '.vcf';

    if ($c->req->param('debug')) {
        $c->res->content_type('text/plain');
    }
    else {
        $c->res->content_type('text/x-vcard');
        $c->res->header('Content-Disposition', "attachment; filename=$filename");
    }

    $c->stash->{template} = 'people/vcard.tt';
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
#        my $phone_number = Phonebook::Util::getPhoneNumber($area_code, $exchange, $last_four);
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

    return Phonebook::Filter::Abstract->new('&')
        ->add($filter)
        ->add($self->_get_restriction);
}

=head2 _get_restriction

Build the default filter for restricting people searches to current
members of the community.

=cut

sub _get_restriction {
    my ($self) = @_;

    my $filter = Phonebook::Filter::Abstract->new('&');
    $filter->add(Phonebook::Filter::Abstract->new('!')->add(qw/eduPersonPrimaryAffiliation = affiliate/));
    $filter->add(Phonebook::Filter::Abstract->new('!')->add(qw/eduPersonPrimaryAffiliation = -*-/));

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
