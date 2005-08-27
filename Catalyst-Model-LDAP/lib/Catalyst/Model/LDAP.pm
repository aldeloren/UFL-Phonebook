package Catalyst::Model::LDAP;

use strict;
use base 'Catalyst::Base';
use NEXT;
use Net::LDAP;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors('client');

=head1 NAME

Catalyst::Model::LDAP - LDAP model class for Catalyst

=head1 SYNOPSIS

  # Use the Catalyst helper
  script/myapp_create.pl model Person LDAP ldap.ufl.edu ou=People,dc=ufl,dc=edu

  # lib/MyApp/Model/Person.pm
  package MyApp::Model::Person;

  use base 'Catalyst::Model::LDAP';

  __PACKAGE__->config(
      host     => 'ldap.ufl.edu',
      base     => 'ou=People,dc=ufl,dc=edu',
      options  => {},
      dn       => '',
      password => '',
  );

  1;

  # As object method
  $c->comp('MyApp::Model::Person')->search('(sn=Test)');

  # As class method
  MyApp::Model::Person->search('(sn=Test)');

=head1 DESCRIPTION

This is the C<Net::LDAP> model class for Catalyst. It is nothing more
than a simple wrapper for C<Net::LDAP>.

=head1 METHODS

=head2 new

Initializes an LDAP connection.

=cut

sub new {
    my $self = shift;

    $self = $self->NEXT::new(@_);

    return $self;
}

=head2 search

Search the directory using a given filter. See L<Net::LDAP> for format
of arguments.

Returns the L<Net::LDAP::Search> object from the C<Net::LDAP::search>
method.

=cut

sub search {
    my ($self, $filter) = @_;

    my $client = Net::LDAP->new($self->config->{host}, %{ $self->config->{options} }) or die $@;

    if ($self->config->{dn} and $self->config->{password}) {
        $client->bind($self->config->{dn}, $self->config->{password});
    }
    else {
        $client->bind;
    }

    my $mesg = $client->search(
        base   => $self->config->{base},
        filter => $filter,
    );

    $client->unbind;

    return $mesg;
}

=head1 SEE ALSO

L<Catalyst>, L<Net::LDAP>

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

Based on work started by E<lt>salih@ip-plus.netE<gt> on the Catalyst
mailing list:

L<http://lists.rawmode.org/pipermail/catalyst/2005-June/000712.html>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
