use strict;
use Net::SCP;
use Data::Dumper;
use FindBin;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/../lib";
use Cfg;

my $win2lin = Cfg::get_struct_from_file('F:\GIT\cfg\win2lin.cfg')->{WIN2LIN};
my $gherkin_editor = Cfg::get_struct_from_file('F:\GIT\cfg\gherkin_editor_files.cfg')->{GHERKIN_EDITOR};

my $target_dir = $win2lin->{TARGET_DIR} . $win2lin->{VERSION};

my $host = $win2lin->{USER} . '@' . $win2lin->{IP};
my $cmd = $win2lin->{SCP} . q{ } . " -i " . $win2lin->{PRIVKEY} . " -r -p " . (join " ", @{ $gherkin_editor->{ FILES } }) . q{ } . $host . ':' .$target_dir;
print $cmd . "\n";
system( $cmd );

