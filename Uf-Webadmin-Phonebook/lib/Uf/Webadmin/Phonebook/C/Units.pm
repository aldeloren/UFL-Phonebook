package Uf::Webadmin::Phonebook::C::Units;

use strict;
use warnings;
use base 'Catalyst::Base';

=head1 NAME

Uf::Webadmin::Phonebook::C::Units - Catalyst component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding units (departments or other
campus organizations).

=head1 METHODS

=head2 default

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->forward('/default');
}

=head2 search

Search the directory for units.

=cut

sub search : Local {
    my ($self, $c) = @_;
}

=head2 show

Display a single unit.

=cut

sub show : Regex('units/([A-Za-z0-9]{8})/?') {
    my ($self, $c) = @_;

    my $ufid = $c->req->snippets->[0];
    $c->log->debug("UFID: $ufid");
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
