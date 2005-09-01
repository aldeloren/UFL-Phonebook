package Uf::Webadmin::Phonebook::C::Units;

use strict;
use base 'Catalyst::Base';

=head1 NAME

Uf::Webadmin::Phonebook::C::Units - Catalyst component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding units.

=head1 METHODS

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->output('Congratulations, Uf::Webadmin::Phonebook::C::Units is on Catalyst!');
}

=head2 search

=cut

sub search : Local {
    my ($self, $c) = @_;
}

=head2 details

Display details for a department.

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
