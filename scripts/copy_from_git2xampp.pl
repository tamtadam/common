use strict;

use File::Copy "cp";
use File::Path;
use File::Spec;

use FindBin;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/../cgi-bin";
use Cfg;
use WinLin;
use Data::Dumper;

my $apache_cfg = Cfg::get_struct_from_file('F:\GIT\cfg\apache_locale.cfg');

$apache_cfg = $apache_cfg->{APACHE};
my ($targetfile, $src_file);
exit unless $ARGV[ 0 ];
$targetfile = $src_file = WinLin::winpath2linpath( $ARGV[ 0 ] );
$targetfile =~s~$apache_cfg->{SOURCE}~$apache_cfg->{APACHE_ROOT}~i;

my $file_name = WinLin::get_filename($targetfile);
my $project_tmpl = WinLin::get_project_from_path($targetfile, $apache_cfg->{APACHE_ROOT} );

if ($project_tmpl =~/common/ ) {
    $targetfile =~s/common//;
}

print "Project: $project_tmpl\n";
print "xampp: $apache_cfg->{APACHE_ROOT}\n";
print $targetfile . "\n";

my @projects = $project_tmpl =~/common/ ? qw(diakontroll gherkin_editor ontozo) :
                                          ($project_tmpl);

for my $project ( @projects ) {
    my $path = WinLin::get_target_path($targetfile, $file_name);
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
}


