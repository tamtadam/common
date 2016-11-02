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

my $file_name = WinLin::get_filename($targetfile);
my $project_tmpl = WinLin::get_project_from_path($targetfile, $apache_cfg->{SOURCE} );
$targetfile =~s~$project_tmpl~~i;
print $targetfile . " target_file\n";
if ($project_tmpl =~/common/ ) {
    $targetfile =~s/common//;
}
$targetfile =~s~$project_tmpl~~;
$targetfile =~s~$apache_cfg->{SOURCE}~~i;
$targetfile =~/\/(.*?)\/(.*)$/i;
my $trg = $1;
$targetfile = $2;

print "Project: $project_tmpl\n";

my @projects = $project_tmpl =~/common/ ? qw(diakontroll gherkin_editor ontozo) :
                                          ($project_tmpl);

for my $project ( @projects ) {
    my $path = $apache_cfg->{APACHE_ROOT} . "/" . $trg . "/" . $project;

    if (!-d $path ) {
      my $dirs = eval { mkpath($path) };
      die "Failed to create $path: $@\n" unless $dirs;
    }

    if(-e $path . "/" . $targetfile) {
        unlink ($path . "/" . $targetfile);
    }

    cp($src_file, $path . "/" . $targetfile);
    print 'cp(' . $src_file . ',' . $path . "/" . $targetfile . ')' . "\n";
}


