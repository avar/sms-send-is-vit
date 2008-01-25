use ExtUtils::MakeMaker;

WriteMakefile(
    NAME		  => 'SMS::Send::IS::Vit',
    AUTHOR        => 'Ævar Arnfjörð Bjarmason <avar@cpan.org>',
    ABSTRACT_FROM => 'Vit.pm',
    VERSION_FROM  => 'Vit.pm',
    LICENSE       => 'perl',
    PREREQ_PM     => {
        # Vit.pm
        'SMS::Send::Driver' => '0.04',
        'LWP::UserAgent'    => 0,
        'HTTP::Cookies'     => 0,

        # t/
        'Test::More' => 0,
    },
);
