use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::Same',
    AUTHOR              => 'Kim Rutherford <kmr+same@xenu.org.uk>',
    VERSION_FROM        => 'lib/Text/Same.pm',
    ABSTRACT_FROM       => 'lib/Text/Same.pm',
    PL_FILES            => {},
    EXE_FILES           => ["bin/psame"],
    SIGN                => 1,
    PREREQ_PM => {
                  'Test::More' => 0,
                  'Term::Size' => 0,
                 },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Text-Same-*' },
);
