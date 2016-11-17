use strict ;
use Net::SCP ;
use Data::Dumper ;
use feature 'state' ;
use FindBin ;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/../cgi-bin" ;
use Cfg ;
use Template ;
use utf8;

my $win2lin = Cfg::get_struct_from_file( $ENV{GIT_ROOT} . '\cfg\win2lin.cfg' ) ;

my $project_name = uc( $ARGV[ 0 ] || 'ontozo' ) ;
my $version = $ARGV[ 1 ] || 'v2_0_2' ;
my @components = $ARGV[ 2 ] // qw(cgi-bin htdocs docs sql tools) ;

my ( $src, $target_dir, $host, $cmd ) ;

print "PROJECT: $project_name\n" ;
print "VERSION: $version\n" ;

foreach my $component ( @components ) {
    $src = change_project_version( $win2lin->{ $project_name }{ SRC }, $component ) ;
    print "\n\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\nCOMPONENT: $component\n" ;
    print $src . "\n" ;
    print "NOT FOUND, can't deploy it: $src\n" and next unless -e $src ;

    $target_dir = $win2lin->{ $project_name }{ TARGET_DIR } . $component . '/' . $version ;
    create_dir_structure( $target_dir ) ;

    $host = $win2lin->{ $project_name }{ USER } . '@' . $win2lin->{ $project_name }{ IP } ;
    $cmd =
        $win2lin->{ $project_name }{ SCP } . q{ } . " -i "
      . $win2lin->{ $project_name }{ PRIVKEY }
      . " -v -r -p "
      . $src . q{ }
      . $host . ':'
      . $target_dir ;

    print $cmd . "\n" ;

    system $cmd;

    create_link( $component, $target_dir ) ;

} ## end foreach my $component ( @components)
execute_command( 'chmod 755 /var/www/cgi-bin/SaveForm1_lin.pl' );

sub create_dir_structure {
    my $target = shift ;
    execute_command( " mkdir -p " . $target );
} ## end sub create_dir_structure

sub create_link {
    my $component = shift ;
    my $target    = shift ;
    my $link_name = $win2lin->{ LINKS }{ uc $component } || return ;

    print "LINK NAME:" . $link_name . "\n" ;
    print "LINK TO  :" . $target . "\n" ;

    execute_command( 'cd /var/www/' );
    execute_command( 'rm /var/www/' . lc $link_name );
    execute_command( 'ln -s ' . $target . " " . '/var/www/' . lc $link_name );
    execute_command( 'pwd' );
} ## end sub create_link

sub execute_command {
    my $cmd = shift;    
    $cmd = get_ssh_access() . " " . $cmd ;
    print $cmd . "\n" ;
    print `$cmd` ;  
}

sub get_ssh_access {
    state $cmd =
        $win2lin->{ $project_name }{ SSH } . " "
      . $win2lin->{ $project_name }{ IP } . " -l "
      . $win2lin->{ $project_name }{ USER } . " -i "
      . $win2lin->{ $project_name }{ PRIVKEY } ;

    return $cmd ;
} ## end sub get_ssh_access

sub change_project_version {
    state $templ = Template->new(
                                  {
                                    "TYPE"   => Template::TYPE->{ STRING },
                                    "SOURCE" => "",
                                  }
                                ) ;
    my $string    = shift ;
    my $component = shift ;
    $templ->change_source( $string ) ;

    $templ->fill_in(
                     {
                       PROJECT_NAME => $project_name,
                       VERSION_NUM  => $version,
                       COMPONENT    => $component,
                     }
                   ) ;

    return $templ->return_string() ;
} ## end sub change_project_version
