package Phonebook;

use strict;
use warnings;
use Scalar::Util;
use YAML;

use Catalyst qw(
    Static::Simple
);

our $VERSION = '0.11';

__PACKAGE__->config(
    YAML::LoadFile(__PACKAGE__->path_to('phonebook.yml')),
);

__PACKAGE__->setup;

=head1 NAME

Phonebook - University of Florida directory search

=head1 SYNOPSIS

    script/phonebook_server.pl

=head1 DESCRIPTION

This application provides a Web interface to the University of Florida
Directory. The application accesses the directory via LDAP, using the
service provided by the Open Systems Group.

L<http://www.bridges.ufl.edu/directory/>
L<http://open-systems.ufl.edu/services/LDAP/>

It is written using the L<Catalyst> framework.

=head1 METHODS

=head2 index

Display the home page.

=cut

sub index : Private {
    my ($self, $c) = @_;

    $c->forward('/people/index');
}

=head2 default

Handle any actions which did not match, i.e. 404 errors.

=cut

sub default : Private {
    my ($self, $c, $path) = @_;

    if ($path) {
        $c->log->debug("Old path = [$path]");

        my $destination;
        if ($path eq 'display_form.cgi') {
            $destination = $c->uri_for('/');

            if (my $query = $c->req->param('person')) {
                $destination = $c->uri_for('/people/search', { query => $query });
            }
        }
        elsif (($path eq 'show.cgi' or $path eq 'show-full.cgi') and my $query = $c->req->uri->query) {
            my $filter = "uflEduUniversityId=" . Phonebook::Util::decode_ufid($query);

            if ($query =~ /^[a-z][-a-z0-9]*$/) {
                $filter = "uid=$query";
            }
            elsif ($query =~ /\+/) {
                my @name     = split('\+', $query);
                my $lastname = pop @name;
                $filter = "cn=$lastname," . join(' ', @name) . '*';
            }

            $c->log->debug("Filter = [$filter]");

            my $mesg = $c->model('Person')->search($filter);
            if (my $entry = $mesg->shift_entry) {
                my $person = Phonebook::Person->new($entry);
                $destination = $c->uri_for('/people', $person, ($path eq 'show-full.cgi' ? 'full/' : ''));
            }
        }

        return $c->res->redirect($destination, 301)
            if $destination;
    }

    $c->res->status(404);
    $c->stash->{template} = '404.tt';
}

=head2 end

Forward to the view.

=cut

sub end : Private {
    my ($self, $c) = @_;

    return 1 if $c->res->status =~ /^3\d\d$/;
    return 1 if $c->res->body;

    if (@{ $c->error }) {
        $c->res->status(500);

        # Override the ugly Catalyst debug screen
        unless ($c->debug) {
            $c->log->error($_) for @{ $c->error };

            $c->stash->{errors} = $c->error;
            $c->error(0);

            $c->stash->{template} = 'error.tt';
        }
    }

    $c->forward($c->view('TT'));
}

##
## Application methods
##

=head2 uri_for

Overload C<uri_for> to handle query parameters and to accept objects
that respond to C<get_url_args>.

=cut

sub uri_for {
    my ($c, $path, @args) = @_;

    my @parts;
    my %query;

    foreach my $arg (@args) {
        if (Scalar::Util::blessed($arg) and $arg->can('get_url_args')) {
            push @parts, $arg->get_url_args;
        }
        elsif (ref $arg eq 'HASH') {
            while (my ($key, $value) = each %$arg) {
                my @values = (ref $value eq 'ARRAY' ? @$value : $value);
                utf8::encode($_) for @values;
                push @{ $query{$key} }, @values;
            }
        }
        else {
            push @parts, $arg;
        }
    }

    my $uri = $c->SUPER::uri_for($path, @parts);
    $uri->query_form(%query);

    return $uri;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
