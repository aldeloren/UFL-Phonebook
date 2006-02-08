package Phonebook;

use strict;
use warnings;
use Scalar::Util;
use YAML;

use Catalyst qw(
    Static::Simple
);

our $VERSION = '0.06';

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
    my ($self, $c) = @_;

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

    # Display errors in the template if we have one; otherwise, use a
    # sensible default
    if (@{ $c->error }) {
        $c->res->status(500);
        $c->log->error($_) for @{ $c->error };
        $c->stash->{errors}     = $c->error;
        $c->stash->{template} ||= 'errors.tt';
        $c->error(0);
    }

    $c->forward($c->view('TT'));
}

=head2 uri_for

Overload C<uri_for> to accept objects that respond to C<get_url_args>.

=cut

sub uri_for {
    my ($c, $path, @args) = @_;

    my @parts;

    foreach my $arg (@args) {
        if (Scalar::Util::blessed($arg) and $arg->can('get_url_args')) {
            push @parts, $arg->get_url_args;
        }
        else {
            push @parts, $arg;
        }
    }

    return $c->SUPER::uri_for($path, @parts);
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
