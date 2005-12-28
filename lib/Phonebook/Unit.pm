package Phonebook::Unit;

use strict;
use warnings;
use base 'Phonebook::Entry';

=head1 NAME

Phonebook::Unit - A unit phonebook entry

=head1 SYNOPSIS

  # Search using Net::LDAP
  my $mesg = $ldap->search($filter);
  my @entries = map {
      Phonebook::Unit->new($_)
  } $mesg->entries;
  print $entries[0]->o;

=head1 DESCRIPTION

A unit or organization in the directory.

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;