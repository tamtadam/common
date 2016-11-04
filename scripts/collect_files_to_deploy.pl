use strict;

use File::Copy "cp";
use File::Copy::Recursive qw(dircopy);
use vars qw(*mycopy);
use File::Path;
use File::Spec;
use Data::Dumper;
use feature 'state';
use FindBin;    
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/../cgi-bin";
use Cfg;
use WinLin;
use Template;

$|=1;
*mycopy = *File::Copy::Recursive::copy;
*File::Copy::Recursive::copy = *WinLin::mycopy_func;

my $deploy = Cfg::get_struct_from_file('F:\GIT\cfg\collect_files_to_deploy.cfg');
my $project_name = uc $ARGV[ 0 ];
my $version      =    $ARGV[ 1 ];
my $component    =    $ARGV[ 2 ] // '';

my $target_dir = delete $deploy->{ $project_name }->{ TARGET };
$target_dir    = change_project_version($target_dir);

foreach my $dir_type ( keys %{ $deploy->{ $project_name } } ) {
    next unless $deploy->{ $project_name }->{ $dir_type }->{ SRC } =~/$component/;

    print 'from:' . $deploy->{ $project_name }->{ $dir_type }->{ SRC } . "\n";
    print 'to  :' . $target_dir . $deploy->{ $project_name }->{ $dir_type }->{ TRG } . "\n";
    dircopy( $deploy->{ $project_name }->{ $dir_type }->{ SRC },
             $target_dir . ( !$component ? $deploy->{ $project_name }->{ $dir_type }->{ TRG } : '') );

}

sub change_project_version {
    state $templ = Template->new({
        "TYPE"   => Template::TYPE->{ STRING }, 
        "SOURCE" => "",
    }) ;
    my $string = shift;
    $templ->change_source($string);

    $templ->fill_in({
        PROJECT_NAME => $project_name,
        VERSION_NUM  => $version,
        COMPONENT    => $component,
    });
    
    return $templ->return_string();
}
