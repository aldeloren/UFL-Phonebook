package Uf::Webadmin::Phonebook::V::TT;

use strict;
use base 'Catalyst::View::TT';
use Uf::Webadmin::Phonebook::Utilities;

=head1 NAME

Uf::Webadmin::Phonebook::V::TT - Template Toolkit view component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>

=head1 DESCRIPTION

The Template Toolkit view component used by L<Uf::Webadmin::Phonebook>.

=head1 METHODS

=head2 new

Configure the Template Toolkit instance used by this application.

=cut

sub new {
    my $self = shift;

    # Cleanup whitespace
    $self->config->{PRE_CHOMP}  = 1;
    $self->config->{POST_CHOMP} = 1;

    # Disable Template::Timer
    $self->config->{CONTEXT} = undef;

    # Additional filters
    $self->config->{FILTERS}->{spam_armor} = \&Uf::Webadmin::Phonebook::Utilities::spamArmor;

    return $self->SUPER::new(@_);
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
