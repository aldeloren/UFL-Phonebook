package Uf::Webadmin::Phonebook;

use strict;
use Catalyst qw/Static -Debug/;

our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'Phonebook',
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

Forward to the home page.

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->forward('home');
}

=head2 home

Display the home page.

=cut

sub home : Path('home') {
    my ($self, $c) = @_;

    $c->stash->{template} = 'home.tt';
}

=head2 end

Forward to the application's view.

=cut

sub end : Private {
    my ($self, $c) = @_;

    # Only forward if we have a template, which allows the Static
    # plugin to serve files
    $c->forward(__PACKAGE__ . '::V::TT') if ($c->stash->{template});
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
