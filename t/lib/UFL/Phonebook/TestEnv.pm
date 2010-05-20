package UFL::Phonebook::TestEnv;

use strict;
use warnings;

sub get {
    my ($class, %overrides) = @_;

    my %env = (
        REMOTE_USER         => 'dwc@ufl.edu',
        glid                => 'dwc',
        ufid                => '13141570',
        primary_affiliation => 'staff',
        %overrides,
    );

    return \%env;
}

sub reset {
    my ($class, %overrides) = @_;

    my %env = (
        REMOTE_USER         => '',
        glid                => '',
        ufid                => '',
        primary_affiliation => '',
        %overrides,
    );

    return \%env;
}

1;
