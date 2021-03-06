package UFL::Phonebook::View::HTML;

use strict;
use warnings;
use base qw/Catalyst::View::TT/;
use Lingua::EN::Numbers ();
use Locale::Country ();
use UFL::Phonebook::Util;

__PACKAGE__->config(
    FILTERS => {
        code2country => \&Locale::Country::code2country,
        num2en       => \&Lingua::EN::Numbers::num2en,
        spam_armor   => \&UFL::Phonebook::Util::spam_armor,
    },
);

=head1 NAME

UFL::Phonebook::View::HTML - Template Toolkit view component

=head1 SYNOPSIS

See L<UFL::Phonebook>.

=head1 DESCRIPTION

The Template Toolkit view component used by L<UFL::Phonebook>.

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
