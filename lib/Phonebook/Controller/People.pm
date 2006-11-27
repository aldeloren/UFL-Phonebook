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

=head2 index

Redirect to the L<Phonebook> home page.

=cut

sub index : Private {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for('/'));
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

    $c->log->debug("Query: $query");
    $c->log->debug("Filter: $filter");

    my $mesg = $c->model('Person')->search($filter->as_string);
    $c->forward('results', [ $mesg ]);
}

=head2 unit

Redirect to C</units/$UFID/people/>.

=cut

sub unit : Local {
    my ($self, $c, $ufid) = @_;

    $c->res->redirect($c->uri_for('/units', $ufid, 'people/'), 301);
}

=head2 results

Display the people from the specified L<Net::LDAP::Message>. If only
one person is found, display him or her directly.

=cut

sub results : Private {
    my ($self, $c, $mesg) = @_;

    $c->stash->{sizelimit_exceeded} = ($mesg->code == &Net::LDAP::Constant::LDAP_SIZELIMIT_EXCEEDED);
    $c->stash->{timelimit_exceeded} = ($mesg->code == &Net::LDAP::Constant::LDAP_TIMELIMIT_EXCEEDED);

    my $sort = $c->req->param('sort') || 'cn';
    my @people =
        sort { $a->$sort cmp $b->$sort }
        map  { Phonebook::Person->new($_) }
        $mesg->entries;

    if (scalar @people == 1) {
        my $person = shift @people;
        $c->res->cookies->{query} = { value => $c->req->param('query') || $person->o };
        $c->res->redirect($c->uri_for('/people', $person, ''));
    }
    elsif (scalar @people > 0) {
        $c->stash->{people}   = \@people;
        $c->stash->{template} = 'people/results.tt';
    }
    else {
        $c->stash->{template} = 'people/noResults.tt';
    }
}

=head2 single

Display a single person. By specifying an argument after the UFID and
providing a corresponding local action, you can override the display
behavior of the person.

=cut

sub single : Path('') {
    my ($self, $c, $ufid, $action) = @_;

    $ufid = Phonebook::Util::decode_ufid($ufid);
    $c->detach('/default') unless $ufid;
    $c->log->debug("UFID: $ufid");

    # Handle redirection when a search query returns only one person
    my $query = $c->req->cookies->{query};
    if ($query and $query->value) {
        $c->stash->{query} = $query->value;
        $c->res->cookies->{query} = { value => '' };

        $c->stash->{single_result} = 1;
    }

    my $mesg = $c->model('Person')->search("uflEduUniversityId=$ufid");
    my $entry = $mesg->shift_entry;
    $c->detach('/default') unless $entry;

    $c->stash->{person}   = Phonebook::Person->new($entry);
    $c->stash->{template} = 'people/show.tt';

    if ($action) {
        $c->detach('/default') unless $self->can($action);
        $c->detach($action);
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
    if ($query =~ /([^@]+)\@/) {
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
    elsif (scalar @tokens == 2) {
        # Two tokens: first and last name
        my ($first, $last) = @tokens;

        ($first, $last) = ($last, $first) if $query =~ /,/;
        $first =~ s/\.$//;

        $filter->add('cn',    '=', qq[$last*,$first*]);
        $filter->add('mail',  '=', qq[$first$last@*]);
        $filter->add('mail',  '=', qq[$first-$last@*]);
        # TODO: Searching title seems slow
#        $filter->add('title', '=', qq[$query*]);
    }
    else {
        # Three or more tokens: first, middle, and last name
        my ($first, $middle, @last) = @tokens;
        my $last = join ' ', @last;

        ($first, $middle, $last) = ($middle, $last, $first) if $query =~ /,/;
        for ($first, $middle) {
            s/\.$//;
        }

        $filter->add('cn',    '=', qq[$last*,$first* $middle*]);
        $filter->add('mail',  '=', qq[$first$last@*]);
        $filter->add('mail',  '=', qq[$first-$last@*]);
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

=head2 redirect_display_form_cgi

Handle requests for C</display_form.cgi> from the old L<Phonebook>
application, which displayed the search form B<and> handled search
queries.

=cut

sub redirect_display_form_cgi : Path('/display_form.cgi') {
    my ($self, $c) = @_;

    my $destination = $c->uri_for('/');

    if (my $query = $c->req->param('person')) {
        $destination = $c->uri_for('/people/search', { query => $query });
    }

    $c->res->redirect($destination, 301);
}

=head2 redirect_show_cgi

Handle requests for C</show.cgi> from the old L<Phonebook>
application, which displayed a single person.

=cut

sub redirect_show_cgi : Path('/show.cgi') {
    my ($self, $c, $full) = @_;

    my $query = $c->req->uri->query;
    return $c->res->redirect($c->uri_for('/'), 301)
        unless $query;

    my $filter = $self->get_show_cgi_filter($query);
    unless ($filter) {
        $c->log->debug("Could not determine filter for [$query]");
        return $c->res->redirect($c->uri_for('/people/search', { query => $query }), 301);
    }

    $c->log->debug("Filter = [$filter]");

    my $mesg = $c->model('Person')->search($filter);
    my $entry = $mesg->shift_entry;
    $c->detach('/default') unless $entry;

    my $person = Phonebook::Person->new($entry);
    return $c->res->redirect($c->uri_for('/people', $person, ($full ? 'full/' : '')), 301);
}

=head2 redirect_show_full_cgi

Handle requests for C</show-full.cgi> from the old L<Phonebook>
application, which displayed the full LDAP entry for a single person.

=cut

sub redirect_show_full_cgi : Path('/show-full.cgi') {
    my ($self, $c) = @_;

    $c->forward('redirect_show_cgi', [ 1 ]);
}

=head2 get_show_cgi_filter

Return a filter for the specified C</show.cgi>-style query from the
old L<Phonebook> application. If no filter could be parsed, return
C<undef>.

=cut

sub get_show_cgi_filter {
    my ($self, $query) = @_;

    my $filter;

    if (my $ufid = Phonebook::Util::decode_ufid($query)) {
        $filter = "uflEduUniversityId=$ufid";
    }
    elsif ($query =~ /^[a-z][-a-z0-9]*$/) {
        $filter = "uid=$query";
    }
    elsif ($query =~ /\+/) {
        my @name = split /\+/, $query;
        my $last = pop @name;
        $filter  = "cn=$last," . join(' ', @name) . '*';
    }

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
