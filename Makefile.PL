use inc::Module::Install;

name     'UFL-Phonebook';
all_from 'lib/UFL/Phonebook.pm';

requires 'Authen::SASL';
requires 'Carp';
requires 'Catalyst' => '5.7006';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::LDAP' => '0.16_01';
requires 'Catalyst::Plugin::Authentication' => '0.10002';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::View::TT';
requires 'Class::Accessor::Fast';
requires 'Class::C3';
requires 'Lingua::EN::Numbers';
requires 'Locale::Country';
requires 'Net::LDAP::Constant';
requires 'Net::LDAP::Control::ProxyAuth';
requires 'Scalar::Util';
requires 'Tree::Simple';
requires 'URI';
requires 'YAML';

build_requires 'File::Spec';
build_requires 'FindBin';
build_requires 'Test::MockObject';
build_requires 'Test::More';
build_requires 'Test::WWW::Mechanize::Catalyst' => '0.40';

catalyst_files;
install_script glob('script/*.pl');

WriteAll;
