use strict;
use warnings;
use Module::Build;
use 5.010;

my $build = Module::Build->new(
    create_readme      => 0,
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Chalice::Model',
    dist_author        => 'Moritz Lenz',
    dist_abstract      => 'Backend for the Chalice blog engine',
    dist_version_from  => 'lib/Chalice/Model.pm',
    requires => {
        perl        => '5.010',
        Mojolicious => '0.040',
    },
    recommends         => {},
    sign               => 0,
);
$build->create_build_script;

# vim: sw=4 ts=4 expandtab
