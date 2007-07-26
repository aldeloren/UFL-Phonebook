package UFL::Phonebook::Filter::Abstract;

use strict;
use UFL::Phonebook::Filter::Abstract::Operator;
use UFL::Phonebook::Filter::Abstract::Predicate;
use Scalar::Util;
use Tree::Simple;
use overload
    '""' => \&as_string;

=head1 NAME

UFL::Phonebook::Filter::Abstract - Generate LDAP filters using a simple API

=head1 SYNOPSIS

    my $filter = UFL::Phonebook::Filter::Abstract->new('&');
    $filter->add(qw/objectClass = person/);
    $filter->add(qw/uid = dwc/);
    print $filter->as_string;

=head1 DESCRIPTION

This module provides an API for generating LDAP filter strings. It is
intended to simplify the process of generating complex filters by
avoiding messy string manipulation.

LDAP filters are typically represented as trees. Thus, this module
provides tree manipulation routines written with LDAP filters in mind.

=head1 METHODS

=head2 new

Create a new LDAP filter. Optionally, provide an operator (see
L<OPERATORS> below). If none is specified, the default (C<&>) is used.

    my $filter = UFL::Phonebook::Filter::Abstract->new;

=cut

sub new {
    my $class = shift;

    my $root = UFL::Phonebook::Filter::Abstract::Operator->new($_[0]);
    my $self = {
        root => $root,
    };
    bless $self, ref($class) || $class;

    return $self;
}

=head2 add

Add an operator or predicate to this LDAP filter.

    # Create an operator
    my $filter2 = UFL::Phonebook::Filter::Abstract->new('!');

    # Add a predicate
    $filter2->add(qw/uid = dwc/);

    # Add the full predicate to the tree
    $filter->add($filter2);

=cut

sub add {
    my $self = shift;

    my $node = $self->_node(@_);
    if ($node) {
        $self->{root}->addChild($node);
    }
    else {
        warn "Error adding node: " . join ', ', @_;
    }

    # Allow chaining of methods
    return $self;
}

=head2 as_string

Generate the LDAP filter string from the current tree.

    print $filter->as_string;

=cut

sub as_string {
    my $self = shift;

    my $string = $self->{root}->as_string;

    return $string;
}

=head2 _node

Private method to generate a node in the filter's tree.

=cut

sub _node {
    my $self = shift;

    my $node = undef;

    if (scalar @_ == 1 and Scalar::Util::blessed($_[0]) and $_[0]->isa(__PACKAGE__)) {
        # Operator node
        $node = $_[0]->{root};
    }
    elsif (scalar @_ == 3) {
        # Predicate
        $node = UFL::Phonebook::Filter::Abstract::Predicate->new(@_);
    }
    else {
        warn "Unknown node type";
    }

    return $node;
}

=head1 OPERATORS

=over 4

=item *

C<&> - logical and

=item *

C<|> - logical or

=item *

C<!> - logical not

=back

=head1 SEE ALSO

L<Net::LDAP::Filter>

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
