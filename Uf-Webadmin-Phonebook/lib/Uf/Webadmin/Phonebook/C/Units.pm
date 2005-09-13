package Uf::Webadmin::Phonebook::C::Units;

use strict;
use warnings;
use base 'Catalyst::Base';
use Uf::Webadmin::Phonebook::Constants;

=head1 NAME

Uf::Webadmin::Phonebook::C::Units - Catalyst component

=head1 SYNOPSIS

See L<Uf::Webadmin::Phonebook>.

=head1 DESCRIPTION

Catalyst controller component for finding units (departments or other
campus organizations).

=head1 METHODS

=head2 default

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_HOME;
}

=head2 search

Search the directory for units.

=cut

sub search : Local {
    my ($self, $c) = @_;
}

=head2 show

Display a single unit.

=cut

sub show : Regex('units/([A-Za-z0-9]{8,9})/?$') {
    my ($self, $c) = @_;

    $c->forward('single');
}

=head2 full

Display details for a single unit.

=cut

sub full : Regex('units/([A-Za-z0-9]{8,9})/full/?$') {
    my ($self, $c) = @_;

    $c->forward('single', [ $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_FULL ]);
}

=head2 single

Display a single unit. Optionally, you can specify a template with
which to display the unit.

=cut

sub single : Private {
    my ($self, $c, $template) = @_;

    $template ||= $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_SHOW;

    my $ufid = $c->req->snippets->[0];
    $c->log->debug("UFID: $ufid");

    eval {
        my $entries = $c->comp('M::Organizations')->search("uflEduUniversityId=$ufid");
        if (scalar @{ $entries }) {
            $c->stash->{unit}     = Uf::Webadmin::Phonebook::Entry->new($entries->[0]);
            $c->stash->{template} = $template;
        }
        else {
            $c->stash->{template} = $Uf::Webadmin::Phonebook::Constants::TEMPLATE_UNITS_NO_RESULTS;
        }
    };
    if ($@) {
        $c->error($@);
    }
}

=head1 AUTHOR

University of Florida Web Administration E<lt>webmaster@ufl.eduE<gt>

L<http://www.webadmin.ufl.edu/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
