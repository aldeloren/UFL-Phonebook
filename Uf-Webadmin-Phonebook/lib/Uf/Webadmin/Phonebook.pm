package Uf::Webadmin::Phonebook;

use strict;
use Catalyst qw/-Debug/;

our $VERSION = '0.01';

Uf::Webadmin::Phonebook->config( name => 'Uf::Webadmin::Phonebook' );

Uf::Webadmin::Phonebook->setup;

=head1 NAME

Uf::Webadmin::Phonebook - Catalyst based application

=head1 SYNOPSIS

    script/uf_webadmin_phonebook_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=over 4

=item default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->output('Congratulations, Uf::Webadmin::Phonebook is on Catalyst!');
}

=back

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
