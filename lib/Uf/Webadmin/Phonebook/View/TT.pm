package Uf::Webadmin::Phonebook::View::TT;

use strict;
use warnings;
use base 'Catalyst::View::TT';
use Locale::Country ();
use Uf::Webadmin::Phonebook::Utilities;

__PACKAGE__->config(
    FILTERS => {
        code2country => \&Locale::Country::code2country,
        spam_armor   => \&Uf::Webadmin::Phonebook::Utilities::spam_armor,
        encode_ufid  => \&Uf::Webadmin::Phonebook::Utilities::encode_ufid,
        decode_ufid  => \&Uf::Webadmin::Phonebook::Utilities::decode_ufid,
    },
);

=head1 NAME

Uf::Webadmin::Phonebook::View::TT - Template Toolkit view component

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
