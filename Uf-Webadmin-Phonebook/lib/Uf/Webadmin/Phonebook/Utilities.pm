package Uf::Webadmin::Phonebook::Utilities;

use strict;

=head1 NAME

Uf::Webadmin::Phonebook::Utilities - Utility functions

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>

=head1 DESCRIPTION

Utility functions for the University of Florida phonebook.

=head1 METHODS

=head2 parseQuery

Given a search query, return the correspoding LDAP search filter as a
L<Uf::Webadmin::Phonebook::Filter>.

=cut

sub parseQuery {
    my ($query) = @_;

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

        $filter = Uf::Webadmin::Phonebook::Filter->new({
            uid  => $uid,
            mail => $uid . '@*',
            mail => $email,
        });
    }
    elsif (scalar @tokens == 1) {  # One token: last name or username
        $filter = Uf::Webadmin::Phonebook::Filter->new({
            cn   => $tokens[0] . ',*',
            uid  => $tokens[0],
            mail => $tokens[0] . '@*',
        });
    }
    else {                         # Two or more tokens: first and last name
        $filter = Uf::Webadmin::Phonebook::Filter->new({
            cn   => $tokens[1] . ',' . $tokens[0] . '*',
            mail => $tokens[1] . '@*',
        });
    }

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
