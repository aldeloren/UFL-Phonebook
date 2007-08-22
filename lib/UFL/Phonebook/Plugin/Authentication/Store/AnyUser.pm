package UFL::Phonebook::Plugin::Authentication::Store::AnyUser;

use strict;
use warnings;
use base qw/Catalyst::Plugin::Authentication::Store::Minimal/;
use Catalyst::Plugin::Authentication::User::Hash;

sub find_user {
    my ($self, $authinfo, $c) = @_;

    my $id = $authinfo->{id} || $authinfo->{username};

    return Catalyst::Plugin::Authentication::User::Hash->new(
        id       => $id,
        password => $id,
    );
}

1;
