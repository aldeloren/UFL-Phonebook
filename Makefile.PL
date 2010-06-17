use inc::Module::Install;

name     'UFL-Phonebook';
all_from 'lib/UFL/Phonebook.pm';

requires 'Authen::SASL';
requires 'Catalyst' => '5.80019';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::User';
requires 'Catalyst::Model::LDAP' => '0.16';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::ErrorCatcher';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::View::TT';
requires 'Class::Accessor::Fast';
requires 'Data::Throttler' => '0.04';  # reset_key
requires 'DateTime';
requires 'Lingua::EN::Numbers';
requires 'Locale::Country';
requires 'MRO::Compat';
requires 'Moose';
requires 'Net::LDAP::Constant';
requires 'Net::LDAP::Control::ProxyAuth';
requires 'Scalar::Util';
requires 'Tree::Simple';
requires 'URI';
requires 'YAML::XS';

build_requires 'Catalyst::Authentication::User::Hash';
build_requires 'File::Spec';
build_requires 'Test::MockObject';
build_requires 'Test::More';
build_requires 'Test::WWW::Mechanize::Catalyst' => '0.40';
build_requires 'Text::vCard::Addressbook';

catalyst_files;
install_script glob('script/*.pl');

WriteAll;
