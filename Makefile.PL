use utf8;
use inc::Module::Install;

name 'SMS-Send-IS-Vit';

author 'Ævar Arnfjörð Bjarmason <avar@cpan.org>';

abstract_from 'Vit.pm';
license_from  'Vit.pm';
version_from  'Vit.pm';

# Vit.pm
requires 'SMS::Send::Driver' => '0.04';
requires 'LWP::UserAgent';
requires 'HTTP::Cookies';

# t/
build_requires 'Test::More' => 0; # 5.007003

tests 't/*.t';

auto_install;
WriteAll;
