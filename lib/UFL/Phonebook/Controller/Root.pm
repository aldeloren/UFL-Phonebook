package UFL::Phonebook::Controller::Root;

use strict;
use warnings;
use base qw/Catalyst::Controller/;

__PACKAGE__->mk_accessors(qw/auto_login/);

__PACKAGE__->config(namespace => '');

=head1 NAME

UFL::Phonebook::Controller::Root - Root controller

=head1 DESCRIPTION

Root L<Catalyst> controller for L<UFL::Phonebook>.

=head1 METHODS

=head2 auto

Automatically log in users if configured to do so.

=cut

sub auto : Private {
    my ($self, $c) = @_;

    # Handle public/private versions of phonebook
    if ($self->auto_login) {
        $c->forward('forbidden') and return 0
            unless $c->authenticate();
    }

    return 1;
}

=head2 default

Handle any actions which did not match, i.e. 404 errors.

=cut

sub default : Private {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->stash(template => 'not_found.tt');
}

=head2 index

Display the home page.

=cut

sub index : Path('') Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'index.tt');
}

=head2 about

Display the about page.

=cut

sub about : Local Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'about.tt');
}

=head2 affiliations

Display the page about university affiliations.

=cut

sub affiliations : Local Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'affiliations.tt');
}

=head2 env

Display the page displaying the user's environment.

=cut

sub env : Local Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'env.tt');
}

=head2 forbidden

Display a message stating that the user is not authorized to view the
requested resource.

=cut

sub forbidden : Private {
    my ($self, $c) = @_;

    $c->res->status(403);
    $c->stash(template => 'forbidden.tt');
}

=head2 unavailable

Display a message stating that the resource in unavailable due to
temporary overloading or maintenance.

=cut

sub unavailable : Private {
    my ($self, $c) = @_;

    $c->res->status(503);
    $c->stash(template => 'unavailable.tt');
}

=head2 render

Attempt to render a view, if needed.

=cut 

sub render : ActionClass('RenderView') {
    my ($self, $c) = @_;

    if (@{ $c->error }) {
        $c->res->status(500);

        # Override the ugly Catalyst debug screen
        unless ($c->debug) {
            $c->log->error($_) for @{ $c->error };

            $c->stash(
                errors   => $c->error,
                template => 'error.tt',
            );
            $c->clear_errors;
        }
    }
}

=head2 end

Render a view and finish up before sending the response.

=cut

sub end : Private {
    my ($self, $c) = @_;

    $c->forward('render');
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
