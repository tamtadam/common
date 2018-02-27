use strict;
use warnings;

use Data::Dumper;
use File::Spec::Functions qw(abs2rel rel2abs);
use File::Basename qw(fileparse dirname basename);
use FindBin;
use TAP::Harness;
use TAP::Parser::Aggregator;
use TAP::Formatter::Console;
use Term::ANSIColor;
use Win32::Console;
use Getopt::Long;
use YAML;
use Readonly;
use Test::Harness qw(execute_tests);
use File::Slurp;

use feature qw(state);

my $path = "..";
my $type = "unit";
my $result_path = ".";

GetOptions (
            "path=s"  => \$path,
            "type=s"  => \$type,
            "results" => \$result_path,
) or die("Missing argument");


my $yaml = YAML::LoadFile( 'f:\GIT\gherkin_editor\build.yaml' );
my $dirname  = dirname( 'f:\GIT\gherkin_editor\build.yaml' );
my $main_dir = dirname( dirname( 'f:\GIT\gherkin_editor\build.yaml' ) );
my $cgi_bin = $main_dir . '/cgi-bin/';


if ( exists $yaml->{ $type } ) {
    print Dumper run_build_config( $yaml->{ $type }, $type, $dirname );

} else {
    print "TYPE is not defined in the given build config\n";

}

sub run_build_config {
    my $build_config = shift || {}     ;
    my $type         = shift || 'unit' ;
    my $dirname      = shift || ''     ;
    $build_config->{ root } = $dirname;
    
    state $type_list = {
        'unit'   => sub {
            set_env( @_ );
            return run_unit_tests( @_ );
        },
        'comp'   => sub{
            
        },
        'system' => sub{
            
        }
    };
    my $res;
    
    if ( exists $build_config->{ 'exec' } ) {
        $res = exec_command( $build_config->{ 'exec' }, $cgi_bin );

    } else {
        $res = &{ $type_list->{ $type } }( $build_config );

    }
    return [ parser( $res, $build_config->{ regexp } ) ];
    
}

sub run_unit_tests {
    my $build_config = shift || {};
    
    my @tests = grep { $_ =~/./ } glob( $build_config->{ root } . $build_config->{ tc_folder } . ( $build_config->{ selector } || '\*.t' ) );

    open my $tap_file, '>', $type . '_test_results.tap' or die "File open error:" . $! ;
    my ($total, $failed) = execute_tests(tests => \@tests, out => $tap_file);
    close $tap_file;

    my $res = read_file(  $type . '_test_results.tap' ) ;
    return $res ;
}

sub exec_command {
    my $cmd = shift || return undef;
    return qx{$cmd $cgi_bin};

}


sub parser {
    my $str           = shift || "";
    my $regexp        = shift || "";
    
    my @match_values = ();
    
    foreach my $line ( split "\n", $str ) {
        if (  $line =~/$regexp/ ) {
            push @match_values, { %+ };

        }

    }

    wantarray ? @match_values : \@match_values ;
}

sub set_env {
    my $build_config = shift || return undef;
    my $env = $build_config->{ env } || {} ;

    $ENV{ $_ } = $env->{ $_ } foreach keys %{ $env } ;
    
    return scalar keys %{ $env } ;

}


