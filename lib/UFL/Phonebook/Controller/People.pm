package UFL::Phonebook::Controller::People;

use strict;
use warnings;
use base qw/UFL::Phonebook::BaseController/;
use UFL::Phonebook::Filter::Abstract;
use UFL::Phonebook::Util;

__PACKAGE__->config(
    model_name => 'Person',
    sort_field => 'cn',
);

=head1 NAME

UFL::Phonebook::Controller::People - People controller component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding people.

=head1 METHODS

=head2 unit

Redirect to C</units/$UFID/people/>.

=cut

sub unit : Local Args(1) {
    my ($self, $c, $ufid) = @_;

    $c->res->redirect($c->uri_for($c->controller('Units')->action_for('people'), [ $ufid ], ''), 301);
}

=head2 single

Display a single person. By specifying an argument after the UFID and
providing a corresponding local action, you can override the display
behavior of the person.

=cut

sub single : PathPart('people') Chained('/') CaptureArgs(1) {
    my ($self, $c, $ufid) = @_;

    $ufid = UFL::Phonebook::Util::decode_ufid($ufid);
    $c->detach('/default') unless $ufid;
    $c->log->debug("UFID: $ufid");

    # Handle redirection when a search query returns only one person
    my $query = $c->req->cookies->{query};
    if ($query and my $value = $query->value) {
        $c->stash(
            query  => $value,
            single => 1,
        );

        $c->res->cookies->{query} = { value => '' };
    }

    my $mesg = $self->model($c)->search("uflEduUniversityId=$ufid");
    die $mesg->error if $mesg->is_error;

    my $entry = $mesg->shift_entry;
    $c->detach('/default') unless $entry;

    $c->stash(entry => $entry);
}

=head2 vcard

Display the vCard for a single person.

=cut

sub vcard : PathPart Chained('single') Args(0) {
    my ($self, $c) = @_;

    my $filename = ($c->stash->{entry}->uid || 'vcard') . '.vcf';

    if ($c->req->param('debug')) {
        $c->res->content_type('text/plain');
    }
    else {
        $c->res->content_type('text/x-vcard');
        $c->res->header('Content-Disposition', "attachment; filename=$filename");
    }

    $c->stash(template => 'people/vcard.tt');
    $c->forward($c->view('vCard'));
}

=head2 redirect_display_form_cgi

Handle requests for C</display_form.cgi> from the old
L<UFL::Phonebook> application, which displayed the search form B<and>
handled search queries.

=cut

sub redirect_display_form_cgi : Path('/display_form.cgi') Args(0) {
    my ($self, $c) = @_;

    my $destination = $c->uri_for($c->controller('Root')->action_for('index'));

    if (my $query = $c->req->param('person')) {
        $destination = $c->uri_for($self->action_for('search'), { query => $query });
    }

    $c->res->redirect($destination, 301);
}

=head2 redirect_show_cgi

Handle requests for C</show.cgi> from the old L<UFL::Phonebook>
application, which displayed a single person.

=cut

sub redirect_show_cgi : Path('/show.cgi') Args(0) {
    my ($self, $c) = @_;

    my $query = $c->req->uri->query;
    return $c->res->redirect($c->uri_for($c->controller('Root')->action_for('index')), 301)
        unless $query;

    my $filter = $self->_get_show_cgi_filter($query);
    $c->log->debug("Filter = [$filter]");

    my $mesg = $self->model($c)->search($filter->as_string);
    my $entry = $mesg->shift_entry;
    $c->detach('/default') unless $entry;

    my $action = $self->action_for('view');
    if ($c->stash->{full}) {
        $action = $self->action_for('full');
    }

    return $c->res->redirect($c->uri_for($action, $entry->uri_args), 301);
}

=head2 redirect_show_full_cgi

Handle requests for C</show-full.cgi> from the old L<UFL::Phonebook>
application, which displayed the full LDAP entry for a single person.

=cut

sub redirect_show_full_cgi : Path('/show-full.cgi') {
    my ($self, $c) = @_;

    $c->stash(full => 1);
    $c->forward('redirect_show_cgi');
}

=head2 filter

Return a new L<UFL::Phonebook::Filter::Abstract> used for finding
people.  This includes a default restriction on affiliation, as
specified by L</_get_restriction>.

=cut

sub filter {
    my ($self, @filter) = @_;

    return UFL::Phonebook::Filter::Abstract->new('&')
        ->add(@filter)
        ->add($self->_get_restriction);
}

=head2 _get_restriction

Build the default filter for restricting people searches to current
members of the community.

=cut

sub _get_restriction {
    my ($self) = @_;

    my $filter = UFL::Phonebook::Filter::Abstract->new('&');
    $filter->add(UFL::Phonebook::Filter::Abstract->new('!')->add(qw/eduPersonPrimaryAffiliation = affiliate/));
    $filter->add(UFL::Phonebook::Filter::Abstract->new('!')->add(qw/eduPersonPrimaryAffiliation = -*-/));

    return $filter;
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
#        my $phone_number = UFL::Phonebook::Util::getPhoneNumber($area_code, $exchange, $last_four);
#
#        $filter->add('homePhone',       '=', qq[$phone_number*]);
#        $filter->add('telephoneNumber', '=', qq[$phone_number*]);
#    }
    elsif (scalar @tokens == 1) {
        # One token: last name or username
        my $name = $tokens[0];

        $filter->add('sn',    '=', qq[$name*]);
        $filter->add('uid',   '=', $name);
        $filter->add('mail',  '=', qq[$name@*]);
        # TODO: Searching title seems slow
#        $filter->add('title', '=', qq[$name*]);
    }
    elsif (scalar @tokens == 2) {
        # Two tokens: first and last name
        my ($first, $last) = @tokens;
        $first =~ s/\.$//;

        my $name_filter = $self->_get_name_filter($first, $last);
        $filter->add($name_filter);

        $filter->add('cn',    '=', qq[$last*, $first*]);
        $filter->add('cn',    '=', qq[$last*,$first*]);
        $filter->add('mail',  '=', qq[$first$last@*]);
        $filter->add('mail',  '=', qq[$first-$last@*]);
        # TODO: Searching title seems slow
#        $filter->add('title', '=', qq[$query*]);
    }
    else {
        # Three or more tokens: default to simple query
        $filter->add('sn', '=', qq[$query*]);

        # Limit number of permutations
        if (@tokens < 5) {
            for (@tokens) {
                s/\.$//;
            }

            # Add all permutations of first and last name from given tokens
            for my $i (1 .. @tokens-1) {
                my $first = join(' ', @tokens[0 .. $i-1]);
                my $last = join(' ', @tokens[$i .. @tokens-1]);

                my $name_filter = $self->_get_name_filter($first, $last);
                $filter->add($name_filter);

                $filter->add('cn',   '=', qq[$last*, *$first*]);
                $filter->add('cn',   '=', qq[$last*,*$first*]);
                $filter->add('mail', '=', qq[$first$last@*]);
                $filter->add('mail', '=', qq[$first-$last@*]);
            }
        }
    }

    return $self->filter($filter);
}

=head2 _get_name_filter

Return a filter for the specified first and last name.  This searches
the C<givenName> and C<sn> fields, respectively, which users can set
on their own.

=cut

sub _get_name_filter {
    my ($self, $first, $last) = @_;

    my $filter = UFL::Phonebook::Filter::Abstract->new('&');
    $filter->add('givenName', '=', qq[*$first*]);
    $filter->add('sn',        '=', qq[$last*]);

    return $filter;
}

=head2 _get_show_cgi_filter

Return a filter for the specified C</show.cgi>-style query from the
old L<UFL::Phonebook> application. If no filter could be parsed,
return C<undef>.

=cut

sub _get_show_cgi_filter {
    my ($self, $query) = @_;

    my $filter = UFL::Phonebook::Filter::Abstract->new('|');

    if (my $ufid = UFL::Phonebook::Util::decode_ufid($query)) {
        $filter->add('uflEduUniversityId', '=', $ufid);
    }
    elsif ($query =~ /^[a-z][-a-z0-9]*$/) {
        $filter->add('uid', '=', $query);
    }
    elsif ($query =~ /\+/) {
        my @name = split /\+/, $query;
        my $last = pop @name;

        my $name = "$last," . join(' ', @name) . '*';
        $filter->add('cn', '=', $name);
    }
    else {
        die 'Invalid query; please stop using show.cgi';
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
