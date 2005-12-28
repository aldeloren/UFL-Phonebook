package Phonebook::Person;

use strict;
use warnings;
use base 'Phonebook::Entry';
use Phonebook::Util;

sub get_url_args {
    my ($self) = @_;

    return Phonebook::Util::encode_ufid($self->uflEduUniversityId);
}

1;
