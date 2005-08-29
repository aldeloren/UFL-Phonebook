package Net::LDAP::Filter::Abstract::Operator;

use strict;
use base 'Net::LDAP::Filter::Abstract';

=head1 NAME

Net::LDAP::Filter::Abstract::Operator - An LDAP operator

=head1 SYNOPSIS


=head1 DESCRIPTION

=head1 METHODS

=head2 new

=cut

sub new {
    my $class = shift;

    my $self = (ref($class) || $class)->SUPER::new($_[0]);

    return $self;
}


=head1 SEE ALSO

L<Net::LDAP::Filter::Abstract>

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
