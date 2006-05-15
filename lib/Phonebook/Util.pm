package Phonebook::Util;

use strict;
use warnings;

# Used to encode and decode UFIDs
our $MASK = 56347812;

=head1 NAME

Phonebook::Util - Utility functions

=head1 SYNOPSIS

See L<Phonebook>.

=head1 DESCRIPTION

Utility functions for the University of Florida phonebook.

=head1 METHODS

=head2 spam_armor

Given an email address, protect against spam harvesting by encoding
each character.

=cut

sub spam_armor {
    my ($email) = @_;

    my $armor = $email;
    $armor =~ s/(.)/'&#' . ord($1) . ';'/eg;

    return $armor;
}

=head2 encode_ufid

Encode the UFID by using an XOR mask, converting to octal, and
translating to letters. This is the same algorithm used in the old
phonebook.

=cut

# TODO: Cleanup
sub encode_ufid {
    my ($ufid) = @_;

    $ufid =~ /^\d{8}$/ or return $ufid;
    my $encoded = sprintf "%9.9o", $ufid ^ $MASK;
    $encoded =~ tr/0-9/TSJWHEVN/;

    return $encoded;
}

=head2 decode_ufid

Decode the UFID by doing the reverse of C<encode_ufid>.

=cut

# TODO: Cleanup
sub decode_ufid {
    my ($encoded) = @_;

    $encoded =~ /^[A-Z]+$/ or return $encoded;
    $encoded =~ tr/TSJWHEVN/0-7/;
    my $ufid = sprintf "%8.8d", oct($encoded) ^ $MASK;

    return $ufid;
}

=head2 tokenize_query

Split a query into tokens, which can then be used to form LDAP
filters.

=cut

# TODO: Cleanup
sub tokenize_query {
    my ($query) = @_;

    # Strip invalid characters
    $query =~ s/[^a-z0-9 .,\-_\'\@\*]//gi;

    my @tokens;
    if ($query =~ /,/) {
        @tokens = split /,\s*/, lc($query);
    }
    else {
        @tokens = split /\s+/, lc($query);
    }

    return @tokens;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
