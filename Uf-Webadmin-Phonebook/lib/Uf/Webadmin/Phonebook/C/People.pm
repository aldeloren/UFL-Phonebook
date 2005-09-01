package Uf::Webadmin::Phonebook::C::People;

use strict;
use base 'Catalyst::Base';

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
    $c->res->output('Congratulations, Uf::Webadmin::Phonebook::C::People is on Catalyst!');
}

=head2 search

=cut

sub search : Local {
    my ($self, $c) = @_;

    my $query = $c->req->params->{query};

    # Strip invalid characters
    $query =~ s/[^a-z0-9 .\-_\'\@]//gi;

    my @tokens = split(/\s+/, lc($query));

    my $filter;
    if ($query =~ m/(.*)\@/) {     # Email address
        my $uid   = $1;
        my $email = shift @tokens;

        $filter = Uf::Webadmin::Phonebook::Filter->new('|', {
            uid  => $uid,
            mail => [ $email, $uid . '@*' ],
        });
    }
    elsif (scalar @tokens == 1) {  # One token: last name or username
        $filter = Uf::Webadmin::Phonebook::Filter->new('|', {
            cn   => $tokens[0] . ',*',
            uid  => $tokens[0],
            mail => $tokens[0] . '@*',
        });
    }
    else {                         # Two or more tokens: first and last name
        $filter = Uf::Webadmin::Phonebook::Filter->new('|', {
            cn   => $tokens[1] . ',' . $tokens[0] . '*',
            mail => $tokens[1] . '@*',
        });
    }

    eval {
        $c->log->debug('Query: ' . $c->req->params->{query});
        $c->log->debug('Filter: ' . $filter->as_string);

        my $mesg = $c->comp('Person')->search($filter->as_string);
        if ($mesg->code) {
            die $mesg->error;
        }

        if ($mesg->entries) {
            my @results = sort { $a->{cn} cmp $b->{cn} } $mesg->entries;

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

Display details for a person.

=cut

sub details : Local {
    my ($self, $c) = @_;

    if (my $ufid = $c->req->arguments->[0]) {
        $c->res->output("UFID: [$ufid]");
    }
    else {
        $c->forward('default');
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
