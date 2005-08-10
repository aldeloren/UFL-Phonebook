package Uf::Webadmin::Phonebook::M::People;

use strict;
use base 'Catalyst::Model::LDAP';

__PACKAGE__->config(
    host     => 'ldap.ufl.edu',
    base     => 'ou=People,dc=ufl,dc=edu',
    dn       => '',
    password => '',
    options  => {},
);

=head1 NAME

Uf::Webadmin::Phonebook::M::People - LDAP Catalyst model component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>

=head1 DESCRIPTION

LDAP Catalyst model component.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
