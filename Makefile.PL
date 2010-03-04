use inc::Module::Install;

name     'UFL-Phonebook';
all_from 'lib/UFL/Phonebook.pm';

requires 'Authen::SASL';
requires 'Catalyst' => '5.80019';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::Credential::Remote';
requires 'Catalyst::Model::LDAP' => '0.16';
requires 'Catalyst::Plugin::Authentication' => '0.10003';  # Store::Null
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::View::TT';
requires 'Class::Accessor::Fast';
requires 'MRO::Compat';
requires 'Lingua::EN::Numbers';
requires 'Locale::Country';
requires 'Net::LDAP::Constant';
requires 'Net::LDAP::Control::ProxyAuth';
requires 'Scalar::Util';
requires 'Tree::Simple';
requires 'URI';
requires 'YAML';

build_requires 'File::Spec';
build_requires 'Test::MockObject';
build_requires 'Test::More';
build_requires 'Test::WWW::Mechanize::Catalyst' => '0.40';
build_requires 'Text::vCard::Addressbook';

catalyst_files;
install_script glob('script/*.pl');

WriteAll;
