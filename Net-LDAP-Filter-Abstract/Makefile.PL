use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Net::LDAP::Filter::Abstract',
    AUTHOR    => 'Daniel Westermann-Clark',
    PREREQ_PM => {
        Scalar::Util => 0,
        Tree::Simple => 0,
    },
    VERSION_FROM => 'lib/Net/LDAP/Filter/Abstract.pm',
);
