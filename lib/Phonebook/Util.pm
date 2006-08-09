package Phonebook::Util;

use strict;
use warnings;

# Used to encode and decode UFIDs
our $MASK   = 56347812;
our $FILTER = 'TSJWHEVN';

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

sub encode_ufid {
    my ($ufid) = @_;

    return unless $ufid =~ /^\d{8}$/;

    # Mask, then convert to octal and zero-pad
    my $encoded = sprintf "%09o", $ufid ^ $MASK;

    # Use an eval so $FILTER is defined at compile time
    eval "\$encoded =~ tr/0-7/$FILTER/, 1" or die $@;

    return $encoded;
}

=head2 decode_ufid

Decode the UFID by doing the reverse of L</encode_ufid>.

=cut

sub decode_ufid {
    my ($encoded) = @_;

    return unless $encoded =~ /^[A-Z]+$/;

    # Use an eval so $FILTER is defined at compile time
    eval "\$encoded =~ tr/$FILTER/0-7/, 1" or die $@;

    # Unmask, then convert back to decimal and zero-pad
    my $ufid = sprintf "%08d", oct($encoded) ^ $MASK;

    return $ufid;
}

=head2 tokenize_query

Split a query into tokens, which can then be used to form LDAP
filters.

=cut

sub tokenize_query {
    my ($query) = @_;

    # Strip invalid characters
    $query =~ s/[^a-z0-9 .,\-_\'\@]//gi;

    my @tokens = split /(?:,\s*|\s+)/, lc($query);

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
