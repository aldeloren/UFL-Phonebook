package Uf::Webadmin::Phonebook;

use strict;
use warnings;
use Uf::Webadmin::Phonebook::Constants;
use YAML;

use Catalyst qw(
    Static::Simple
);

our $VERSION = '0.03';

__PACKAGE__->config(
    YAML::LoadFile(__PACKAGE__->path_to('Phonebook.yml')),
);

__PACKAGE__->setup;

=head1 NAME

Uf::Webadmin::Phonebook - Catalyst based application

=head1 SYNOPSIS

  script/uf_webadmin_phonebook_server.pl

=head1 DESCRIPTION

This application provides a Web interface to the University of Florida
Directory. The application accesses the directory via LDAP, using the
service provided by the Open Systems Group.

L<http://www.bridges.ufl.edu/directory/>
L<http://open-systems.ufl.edu/services/LDAP/>

It is written using the L<Catalyst> framework.

=head1 METHODS

=head2 default

Display the home page.

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_HOME;
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
        $c->stash->{template} ||= $Uf::Webadmin::Phonebook::Constants::TEMPLATE_ERRORS;
        $c->error(0);
    }

    $c->forward($c->view('TT'));
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
