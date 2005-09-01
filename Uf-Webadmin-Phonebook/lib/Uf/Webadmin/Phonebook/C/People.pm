package Uf::Webadmin::Phonebook::C::People;

use strict;
use base 'Catalyst::Base';
use Net::LDAP::Filter::Abstract;

=head1 NAME

Uf::Webadmin::Phonebook::C::People - Catalyst component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding people.

=head1 METHODS

=head2 default

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->forward('/default');
}

=head2 search

=cut

sub search : Local {
    my ($self, $c) = @_;

    eval {
        my $query = $c->request->param('query');
        my $filter = $self->_parseQuery($query);
        my $filterString = $filter->as_string;

        $c->log->debug('Query: ' . $query);
        $c->log->debug('Filter: ' . $filterString);

        my $mesg = $c->component('Person')->search($filterString);
        if ($mesg->code) {
            die $mesg->error;
        }

        if ($mesg->entries) {
            my @results = sort { $a->get_value('cn') cmp $b->get_value('cn') } $mesg->entries;

            $c->stash->{results}  = \@results;
            $c->stash->{template} = 'people/results.tt';
        }
        else {
            $c->stash->{template} = 'people/noResults.tt';
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head2 details

Display a single person.

=cut

# TODO: Trailing slash - 301 redirect
sub show : Regex('people/([A-Za-z0-9]{8,9})') {
    my ($self, $c) = @_;

    if (my $ufid = $c->request->snippets->[0]) {
        $ufid = Uf::Webadmin::Phonebook::Utilities::decodeUfid($ufid);
        $c->response->output("UFID = [$ufid]");
    }
    else {
        $c->forward('default');
    }
}

=head2 _parseQuery

=cut

sub _parseQuery {
    my ($self, $query) = @_;

    # Strip invalid characters
    $query =~ s/[^a-z0-9 .\-_\'\@]//gi;

    my @tokens = split(/\s+/, lc($query));

    my $filter = Net::LDAP::Filter::Abstract->new('|');
    if ($query =~ m/(.*)\@/) {     # Email address
        my $uid   = $1;
        my $email = shift @tokens;

        $filter->add('uid', '=', $uid);
        $filter->add('mail', '=', $email);
        $filter->add('mail', '=', $uid . '@*');
    }
    elsif (scalar @tokens == 1) {  # One token: last name or username
        $filter->add('cn', '=', $tokens[0] . ',*');
        $filter->add('uid', '=', $tokens[0]);
        $filter->add('mail', '=', $tokens[0] . '@*');
    }
    else {                         # Two or more tokens: first and last name
        $filter->add('cn', '=', $tokens[1] . ',' . $tokens[0] . '*');
        $filter->add('mail', '=', $tokens[1] . '@*');
    }

    my $filter = Net::LDAP::Filter::Abstract->new('&')->add($filter);

    my $restriction = Net::LDAP::Filter::Abstract->new('!');
    $restriction->add(qw/eduPersonPrimaryAffiliation = affiliate/);
    $restriction->add(qw/eduPersonPrimaryAffiliation = -*-/);
    $filter->add($restriction);

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
