package Net::LDAP::Filter::Abstract;

use strict;

our $VERSION = '0.01';

=head1 NAME

Net::LDAP::Filter::Abstract - Generate LDAP filters using a simple API

=head1 SYNOPSIS


=head1 DESCRIPTION



=head1 METHODS

=head2 new



=cut

sub new {
    my $self = shift;

    $self = $self->NEXT::new(@_);

    return $self;
}


=head1 SEE ALSO

L<Net::LDAP::Filter>

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
