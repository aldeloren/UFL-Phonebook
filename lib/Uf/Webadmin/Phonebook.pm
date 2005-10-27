package Uf::Webadmin::Phonebook;

use strict;
use warnings;
use Catalyst;
use File::Spec;
use Uf::Webadmin::Phonebook::Constants;
use YAML;

our $VERSION = '0.01';

__PACKAGE__->config(
    YAML::LoadFile(File::Spec->join(__PACKAGE__->config->{home}, 'phonebook.yml')),
);

my @plugins = qw/Static::Simple/;
push(@plugins, '-Debug') if $ENV{USER};

__PACKAGE__->setup(@plugins);

=head1 NAME

Uf::Webadmin::Phonebook - Catalyst based application

=head1 SYNOPSIS

  script/uf_webadmin_phonebook_server.pl

=head1 DESCRIPTION

This application provides a Web interface to the University of Florida
Directory. The application accesses the directory via LDAP, using the
service provided by the Open Systems Group.

L<http://www.bridges.ufl.edu/directory/>
L<http://open-systems.ufl.edu/services/LDAP/>

It is written using the L<Catalyst> framework.

=head1 METHODS

=head2 default

Display the home page.

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_HOME;
}

=head2 end

Forward to the view.

=cut

sub end : Private {
    my ($self, $c) = @_;

    # Display errors in the template if we have one; otherwise, use a
    # sensible default
    if (scalar @{ $c->error }) {
        $c->stash->{errors}     = $c->error;
        $c->stash->{template} ||= $Uf::Webadmin::Phonebook::Constants::TEMPLATE_ERRORS;
        $c->{error} = [];
    }

    $c->forward(__PACKAGE__ . '::V::TT') if ($c->stash->{template});
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
