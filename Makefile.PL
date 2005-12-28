use inc::Module::Install;

name     'Phonebook';
all_from 'lib/Phonebook.pm';

requires 'Catalyst'              => '5.60';
requires 'Catalyst::Model::LDAP' => '0.08';
requires 'Catalyst::View::TT';
requires 'Class::Accessor';
requires 'Locale::Country';
requires 'Scalar::Util';
requires 'Tree::Simple';
requires 'UNIVERSAL';
requires 'YAML';

build_requires 'Test::More';

catalyst_files;
install_script glob('script/*.pl');

WriteAll;
