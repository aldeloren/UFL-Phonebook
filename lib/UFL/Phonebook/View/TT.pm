package UFL::Phonebook::View::TT;

use strict;
use warnings;
use base 'Catalyst::View::TT';
use Lingua::EN::Numbers ();
use Locale::Country ();
use UFL::Phonebook::Util;

__PACKAGE__->config(
    FILTERS => {
        code2country => \&Locale::Country::code2country,
        num2en       => \&Lingua::EN::Numbers::num2en,
        spam_armor   => \&UFL::Phonebook::Util::spam_armor,
        encode_ufid  => \&UFL::Phonebook::Util::encode_ufid,
        decode_ufid  => \&UFL::Phonebook::Util::decode_ufid,
    },
);

=head1 NAME

UFL::Phonebook::View::TT - Template Toolkit view component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

The Template Toolkit view component used by L<UFL::Phonebook>.

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
