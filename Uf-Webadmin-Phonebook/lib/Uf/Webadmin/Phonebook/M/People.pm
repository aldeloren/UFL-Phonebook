package Uf::Webadmin::Phonebook::M::People;

use strict;
use base 'Catalyst::Model::LDAP';

__PACKAGE__->config(
    host     => Uf::Webadmin::Phonebook->config->{ldap_host},
    base     => 'ou=People,' . Uf::Webadmin::Phonebook->config->{ldap_base},
    dn       => '',
    password => '',
    options  => {},
);

=head1 NAME

Uf::Webadmin::Phonebook::M::People - LDAP Catalyst model component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>

=head1 DESCRIPTION

Catalyst model component for the University of Florida LDAP server.
This component uses a base of C<ou=People,dc=ufl,dc=edu>.

=head1 METHODS

=head2 search

Search the directory for a person.

=cut

sub search {
    my ($self, $query) = @_;

    if ($query =~ /[^a-z0-9 ._\'*\-\@]/) {
        die 'Query contains invalid characters';
    }

    my $filter = $self->_parseQuery($query);
    $self->SUPER::search($filter);
}

=head2 _parseQuery

=cut

sub _parseQuery {
    my ($self, $query) = @_;

    my @tokens = split(/\s+/, lc($query));

    my $filter;
    if (my $pos = $query =~ m/\@/) {
        my $email = shift @tokens;
        $filter = 'email=' . $email;
    }
    else {
        $filter = 'sn=' . $query;
    }

    Uf::Webadmin::Phonebook->log->debug("Filter: $filter");

    return $filter;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
