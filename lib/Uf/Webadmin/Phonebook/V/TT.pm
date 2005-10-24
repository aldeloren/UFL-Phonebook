package Uf::Webadmin::Phonebook::V::TT;

use strict;
use warnings;
use base 'Catalyst::View::TT';
use Uf::Webadmin::Phonebook::Utilities;

__PACKAGE__->config(
    PRE_CHOMP  => 1,
    POST_CHOMP => 1,
    CONTEXT    => undef,
    FILTERS    => {
        spam_armor  => \&Uf::Webadmin::Phonebook::Utilities::spamArmor,
        encode_ufid => \&Uf::Webadmin::Phonebook::Utilities::encodeUfid,
        decode_ufid => \&Uf::Webadmin::Phonebook::Utilities::decodeUfid,
    },
);

=head1 NAME

Uf::Webadmin::Phonebook::V::TT - Template Toolkit view component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>.

=head1 DESCRIPTION

The Template Toolkit view component used by L<Uf::Webadmin::Phonebook>.

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
