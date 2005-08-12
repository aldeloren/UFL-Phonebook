package Uf::Webadmin::Phonebook::Utilities;

use strict;

# Used to encode and decode UFIDs
my $MASK = 56347812;

=head1 NAME

Uf::Webadmin::Phonebook::Utilities - Utility functions

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>

=head1 DESCRIPTION

Utility functions for the University of Florida phonebook.

=head1 METHODS

=head2 spamArmor

Given an email address, protect against spam harvesting by encoding
each character.

=cut

sub spamArmor {
    my ($email) = @_;

    my $armor = $email;
    $armor =~ s/(.)/'&#' . ord($1) . ';'/eg;

    return $armor;
}

=head2 encodeUfid

Encode the UFID by using an XOR mask, converting to octal, and
translating to letters. This is the same algorithm used in the old
phonebook.

=cut

sub encodeUfid {
    my ($string) = @_;

    $string =~ m/^\d{8}$/ or return $string;
    my $encoded = sprintf "%9.9o", $string ^ $MASK;
    $encoded =~ tr/0-9/TSJWHEVN/;

    return $encoded;
}

=head2 decodeUfid

Decode the UFID by doing the reverse of C<encodeUfid>.

=cut

sub decodeUfid {
    my ($string) = @_;

    $string =~ m/^[A-Z]+$/ or return $string;
    $string =~ tr/TSJWHEVN/0-7/;
    my $decoded = sprintf "%8.8d", oct($string) ^ $MASK;

    return $decoded;
}

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