package Uf::Webadmin::Phonebook::M::People;

use strict;
use base 'Catalyst::Model::LDAP';
use Uf::Webadmin::Phonebook::Filter;

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

    my $filter = $self->_parseQuery($query);
    $self->SUPER::search($filter);
}

=head2 _parseQuery

Parse the specified query into an LDAP filter.

=cut

sub _parseQuery {
    my ($self, $query) = @_;

    # Remove wildcards
    $query =~ tr/\*//d;

    if ($query =~ m/[^a-z0-9 .\-_\'\@]/i) {
        die 'Query contains invalid characters';
    }

    my @tokens = split(/\s+/, lc($query));

    my $filter;
    if ($query =~ m/(.*)\@/) {     # Email address
        my $uid   = $1;
        my $email = shift @tokens;

        $filter = Uf::Webadmin::Phonebook::Filter->new(
            uid  => $uid,
            mail => $email,
        );
    }
    elsif (scalar @tokens == 1) {  # One token: username or last name
        $filter = Uf::Webadmin::Phonebook::Filter->new(
            mail => $tokens[0] . '@*',
            uid  => $tokens[0],
            cn   => $tokens[0] . ',*',
        );
    }
    elsif (scalar @tokens == 2) {  # Two tokens: first and last name
    }
    else {
    }

    # TODO: Add default filter on affiliation

    Uf::Webadmin::Phonebook->log->debug("Query: $query");
    Uf::Webadmin::Phonebook->log->debug('Filter: ' . $filter->toString);

    return $filter->toString;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
