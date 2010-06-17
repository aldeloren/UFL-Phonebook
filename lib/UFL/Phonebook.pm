package UFL::Phonebook;

use strict;
use warnings;

use Catalyst qw/
    ConfigLoader
    Authentication
    Authorization::Roles
    ErrorCatcher
    StackTrace
    Static::Simple
/;

our $VERSION = '0.38_01';

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

=head2 finalize_error

Output a more friendly error page. This is based loosely on
L<Catalyst::Plugin::CustomErrorMessage>.

=cut

sub finalize_error {
    my $c = shift;

    # Allow ErrorCatcher to run
    $c->next::method(@_);

    # Allow StackTrace to take over in debug mode
    return if $c->debug;

    # Forward to the more friendly error page
    eval {
        $c->res->body($c->view('HTML')->render($c, 'error.tt'));
    };
    if ($@) {
        # Handle view-level errors by logging them
        $c->log->error($@);
    }
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
