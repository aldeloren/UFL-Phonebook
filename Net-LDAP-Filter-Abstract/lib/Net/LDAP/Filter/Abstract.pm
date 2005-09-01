package Net::LDAP::Filter::Abstract;

use strict;
use Data::Dumper;
use Scalar::Util;
use Tree::Simple;
use Net::LDAP::Filter::Abstract::Operator;
use Net::LDAP::Filter::Abstract::Predicate;

our $VERSION = '0.01';

=head1 NAME

Net::LDAP::Filter::Abstract - Generate LDAP filters using a simple API

=head1 SYNOPSIS

  my $filter = Net::LDAP::Filter::Abstract->new('&');
  $filter->add(qw/objectClass = person/);
  $filter->add(qw/uid = dwc/);
  print $filter->as_string();

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

=cut

sub new {
    my $class = shift;

    my $root = Net::LDAP::Filter::Abstract::Operator->new($_[0]);
    my $self = {
        root => $root,
    };
    bless $self, ref($class) || $class;

    return $self;
}

=head2 add

Add an operator or predicate to this LDAP filter.

=cut

sub add {
    my $self = shift;

    my $node = $self->_node(@_);
    if ($node) {
        $self->{root}->addChild($node);
    }
}

=head2 as_string

Generate the LDAP filter string from the current tree.

=cut

sub as_string {
    my $self = shift;

    my $string = $self->{root}->as_string;

    return $string;
}

sub _node {
    my $self = shift;

    my $node = undef;

    if (scalar @_ == 1) {     # Operator or node
        if ($_[0]->isa('Tree::Simple')) {
            $node = $_[0];
        }
        else {
            $node = Net::LDAP::Filter::Abstract::Operator->new($_[0]);
        }
    }
    elsif (scalar @_ == 3) {  # Predicate
        $node = Net::LDAP::Filter::Abstract::Predicate->new(@_);
    }
    else {
        warn "Unknown node type";
    }

    return $node;
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
