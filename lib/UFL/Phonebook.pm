package UFL::Phonebook;

use strict;
use warnings;
use Scalar::Util;

use Catalyst qw/
    ConfigLoader
    Static::Simple
/;

our $VERSION = '0.20_01';

__PACKAGE__->setup;

=head1 NAME

UFL::Phonebook - University of Florida directory search

=head1 SYNOPSIS

    script/ufl_phonebook_server.pl

=head1 DESCRIPTION

This application provides a Web interface to the University of Florida
Directory. The application accesses the directory via LDAP, using the
service provided by the Open Systems Group.

L<http://www.bridges.ufl.edu/directory/>
L<http://open-systems.ufl.edu/services/LDAP/>

It is written using the L<Catalyst> framework.

=head1 METHODS

=head2 uri_for

Overload C<uri_for> to handle query parameters and to accept objects
that respond to C<get_url_args>.

=cut

sub uri_for {
    my ($c, $path, @args) = @_;

    my @parts;
    my %query;

    foreach my $arg (@args) {
        if (Scalar::Util::blessed($arg) and $arg->can('get_url_args')) {
            push @parts, $arg->get_url_args;
        }
        elsif (ref $arg eq 'HASH') {
            while (my ($key, $value) = each %$arg) {
                my @values = (ref $value eq 'ARRAY' ? @$value : $value);
                utf8::encode($_) for @values;
                push @{ $query{$key} }, @values;
            }
        }
        else {
            push @parts, $arg;
        }
    }

    my $uri = $c->SUPER::uri_for($path, @parts);
    $uri->query_form(%query);

    return $uri;
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
