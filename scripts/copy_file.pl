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

my $apache_cfg = Cfg::get_struct_from_file('F:\GIT\cfg\copy_to_apache_locale.cfg');

$apache_cfg = $apache_cfg->{APACHE};
my ($targetfile, $src_file);
$targetfile = $src_file = WinLin::winpath2linpath( $ARGV[ 0 ] );
$targetfile =~s~$apache_cfg->{SOURCE}~$apache_cfg->{APACHE_ROOT}~i;

my $file_name = WinLin::get_filename($targetfile);
my $path = WinLin::get_target_path($targetfile, $file_name);
my $project = WinLin::get_project_from_path($targetfile, $apache_cfg->{APACHE_ROOT} );

$path =~s/$project//;
$path .="/$project";

if (!-d $path ) {
  my $dirs = eval { mkpath($path) };
  die "Failed to create $path: $@\n" unless $dirs;
}

if(-e $path . "/" . $file_name) {
    unlink ($path . "/" . $file_name);
}

cp($src_file, $path . "/" . $file_name);
print 'cp(' . $src_file . ',' . $path . "/" . $file_name . ')' . "\n";
