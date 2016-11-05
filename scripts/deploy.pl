use strict;
use Net::SCP;
use Data::Dumper;
use feature 'state';
use FindBin;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/../cgi-bin";
use Cfg;
use Template;

my $win2lin = Cfg::get_struct_from_file('F:\GIT\cfg\win2lin.cfg');

my $project_name = uc ($ARGV[ 0 ] || 'ontozo');
my $version      =    $ARGV[ 1 ] || 'v2_0_2';
my @components   =    $ARGV[ 2 ] // qw(cgi-bin htdocs docs sql tools);

my ($src, $target_dir, $host, $cmd);

foreach my $component ( @components ) {
    $src        = change_project_version($win2lin->{ $project_name }{ SRC }, $component);
    next unless -e $src;

    $target_dir = $win2lin->{ $project_name }{ TARGET_DIR } . $component . '/' . $version;
    $host       = $win2lin->{ $project_name }{USER} . '@' . $win2lin->{ $project_name }{IP};
    $cmd        = $win2lin->{ $project_name }{SCP} .
                  q{ } .
                  " -i " . $win2lin->{ $project_name }{PRIVKEY} .
                  " -v -r -p " .
                  $src . q{ } .
                  $host . ':' . $target_dir;

    print $cmd . "\n";
    system $cmd;
}


sub change_project_version {
    state $templ = Template->new({
        "TYPE"   => Template::TYPE->{ STRING },
        "SOURCE" => "",
    }) ;
    my $string    = shift;
    my $component = shift;
    $templ->change_source($string);

    $templ->fill_in({
        PROJECT_NAME => $project_name,
        VERSION_NUM  => $version,
        COMPONENT    => $component,
    });

    return $templ->return_string();
}
