use strict;

use File::Copy "cp";
use File::Path;
use File::Spec;

use FindBin;    
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/../lib";
use Cfg;
use WinLin;
use Data::Dumper;


my $deploy = Cfg::get_struct_from_file('F:\GIT\cfg\collect_files_to_deploy.cfg');
my $project_name = $ARGV[0];
my $version = $ARGV[1];



print Dumper $deploy;
