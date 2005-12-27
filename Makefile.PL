use inc::Module::Install;

name('Phonebook');
author('University of Florida Web Administration <webmaster@ufl.edu>');
abstract_from('lib/Uf/Webadmin/Phonebook.pm');
version_from('lib/Uf/Webadmin/Phonebook.pm');
license('perl');

requires('Catalyst' => '5.60');
requires('Catalyst::Model::LDAP');
requires('Catalyst::View::TT');
requires('Class::Accessor');
requires('Locale::Country');
requires('Scalar::Util');
requires('Tree::Simple');
requires('YAML');

build_requires('Test::More');

catalyst_files();

install_script(glob('script/*.pl'));

&WriteAll;
