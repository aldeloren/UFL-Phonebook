use strict;
use Catalyst::Build;

my $build = Catalyst::Build->new(
    module_name        => 'Uf::Webadmin::Phonebook',
    license            => 'perl',
    requires           => {
        'Catalyst'              => '5.33',
        'Catalyst::Model::LDAP' => '0',
        'Catalyst::View::TT'    => '0',
        'Class::Accessor'       => '0',
        'Scalar::Util'          => '0',
        'Tree::Simple'          => '0',
        'YAML'                  => '0',
    },
    script_files       => [ glob('script/*') ],
    test_files         => [ glob('t/*.t'), glob('t/*/*.t') ],
    create_makefile_pl => 'passthrough',
);
$build->create_build_script;
