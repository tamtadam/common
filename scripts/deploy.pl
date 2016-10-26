use strict;
use Net::SCP;
use Data::Dumper;
use feature 'state';
use FindBin;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/../cgi-bin";
use Cfg;
use Template;

my $win2lin = Cfg::get_struct_from_file('F:\GIT\cfg\win2lin.cfg')->{WIN2LIN};
#my $gherkin_editor = Cfg::get_struct_from_file('F:\GIT\cfg\gherkin_editor_files.cfg')->{GHERKIN_EDITOR};

my $project_name = uc $ARGV[0];
my $version = $ARGV[1];
my $src = $win2lin->{ SRC };
$src = change_project_version($src);

my $target_dir = $win2lin->{TARGET_DIR} . $version;

my $host = $win2lin->{USER} . '@' . $win2lin->{IP};
my $cmd = "cmd.exe " . $win2lin->{SCP} . q{ } . " -batch -i " . $win2lin->{PRIVKEY} . " -r -p " . $src . q{ } . $host . ':' .$target_dir;
print $cmd . "\n";
system( $cmd );

sub change_project_version {
    state $templ = Template->new({
        "TYPE"   => Template::TYPE->{ STRING }, 
        "SOURCE" => "pid_t TASK_NAME_tid= -1;",
    }) ;
    my $string = shift;
    $templ->change_source($string);

    $templ->fill_in({
        PROJECT_NAME => $project_name,
        VERSION_NUM  => $version
    });
    
    return $templ->return_string();
}
