package Uf::Webadmin::Phonebook::C::Static;

use strict;
use base 'Catalyst::Base';

=head1 NAME

Uf::Webadmin::Phonebook::C::Static - Static content controller component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>

=head1 DESCRIPTION

Serve static content through L<Catalyst::Plugin::Static>.

=head1 METHODS

=head2 default

Handle requests for any content found in the project directory
C<root/static/>.

=cut

sub default : Path('/static') {
    my ($self, $c) = @_;

    # Serve content through Catalyst::Plugin::Static
    $c->serve_static;
}

=head2 favicon

Handle requests for C</favicon.ico>.

=cut

sub favicon : Path('/favicon.ico') {
    my ($self, $c) = @_;

    # Serve content through Catalyst::Plugin::Static
    $c->serve_static;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
