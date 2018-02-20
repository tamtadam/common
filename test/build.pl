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

use feature qw(state);

my $path = "..";
my $type = "unit";
my $result_path = ".";

GetOptions (
            "path=s"  => \$path,
            "type=s"  => \$type,
            "results" => \$result_path,
) or die("Missing argument");


my $yaml = YAML::LoadFile( 'f:\GIT\gherkin_editor\test\build.yaml' );
my $dirname  = dirname( 'f:\GIT\gherkin_editor\test\build.yaml' );
my $main_dir = dirname( dirname( 'f:\GIT\gherkin_editor\test\build.yaml' ) );
my $cgi_bin = $main_dir . '/cgi-bin/';


if ( exists $yaml->{ $type } ) {
    run_build_config( $yaml->{ $type }, $type );

} else {
    print "TYPE is not defined in the given build config\n";

}

sub run_build_config {
    my $build_config = shift || {};
    my $type         = shift;

    state $type_list = {
        'unit'   => \&run_unit_tests,
        'comp'   => sub{},
        'system' => sub{}
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

    $ENV{HARNESS_OPTIONS}       = 'j4:c';
    $ENV{HARNESS_TIMER}         = 1;
    $ENV{HARNESS_PERL_SWITCHES} = '';
    $ENV{HARNESS_PERL_SWITCHES} .=' -MDevel::Cover=-db,cover_db,-ignore,\.t';

    my @tests = grep { $_ =~/./ } glob( $build_config->{ tc_folder } . ( $build_config->{ selector } || '\*.t' ) );

    print $ENV{HARNESS_PERL_SWITCHES} . "\n";
    open my $tap_file, '>', $type . '_test_results.tap' or die "File open error:" . $! ;
    my ($total, $failed) = execute_tests(tests => \@tests, out => $tap_file);
    close $tap_file;

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
