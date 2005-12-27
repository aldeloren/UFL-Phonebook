package Phonebook::Constants;

use strict;
use warnings;
use File::Spec;

=head1 NAME

Phonebook::Constants - Application constants

=cut

=head1 SYNOPSIS

See L<Phonebook>.

=cut

=head1 DESCRIPTION

This package contains constants which define template locations for
the phonebook.

=cut

our $TEMPLATE_HOME       = 'index.tt';
our $TEMPLATE_ERRORS     = 'errors.tt';
our $TEMPLATE_RESULTS    = 'results.tt';
our $TEMPLATE_NO_RESULTS = 'noResults.tt';
our $TEMPLATE_SHOW       = 'show.tt';
our $TEMPLATE_FULL       = 'full.tt';
our $TEMPLATE_VCARD      = 'vcard.tt';

our $DIRECTORY_PEOPLE = 'people';
our $TEMPLATE_PEOPLE_RESULTS    = File::Spec->join($DIRECTORY_PEOPLE, $TEMPLATE_RESULTS);
our $TEMPLATE_PEOPLE_NO_RESULTS = File::Spec->join($DIRECTORY_PEOPLE, $TEMPLATE_NO_RESULTS);
our $TEMPLATE_PEOPLE_SHOW       = File::Spec->join($DIRECTORY_PEOPLE, $TEMPLATE_SHOW);
our $TEMPLATE_PEOPLE_FULL       = File::Spec->join($DIRECTORY_PEOPLE, $TEMPLATE_FULL);
our $TEMPLATE_PEOPLE_VCARD      = File::Spec->join($DIRECTORY_PEOPLE, $TEMPLATE_VCARD);

our $DIRECTORY_UNITS = 'units';
our $TEMPLATE_UNITS_RESULTS    = File::Spec->join($DIRECTORY_UNITS, $TEMPLATE_RESULTS);
our $TEMPLATE_UNITS_NO_RESULTS = File::Spec->join($DIRECTORY_UNITS, $TEMPLATE_NO_RESULTS);
our $TEMPLATE_UNITS_SHOW       = File::Spec->join($DIRECTORY_UNITS, $TEMPLATE_SHOW);
our $TEMPLATE_UNITS_FULL       = File::Spec->join($DIRECTORY_UNITS, $TEMPLATE_FULL);

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
