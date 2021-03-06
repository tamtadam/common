use strict;
use warnings;

use Data::Dumper; 
use File::Spec::Functions qw(abs2rel rel2abs);  
use File::Basename qw(fileparse); 
use FindBin;      
use TAP::Harness;            
use TAP::Parser::Aggregator; 
use TAP::Formatter::Console; 
use Term::ANSIColor;         
use Getopt::Long;

use lib "$FindBin::RealBin/../cgi-bin/";
use lib 'f:\\GIT\\gherkin_editor\\cgi-bin\\';

use JSON qw(encode_json decode_json);
use Win32::Console;

use Readonly;
use Test::Harness qw(execute_tests);

my $CONSOLE = Win32::Console->new(STD_OUTPUT_HANDLE);
my $attr = $CONSOLE->Attr();

my $path = "..";
my $type = "unit";
my $result_path = ".";

GetOptions (
            "path=s"  => \$path,
            "type=s"  => \$type,
            "results" => \$result_path,
) or die("Missing argument");



my @tests = grep { $_ =~/./ } glob( $path . '\*.t' );

$ENV{HARNESS_OPTIONS}       = 'j4:c';
$ENV{HARNESS_TIMER}         = 1;
$ENV{HARNESS_PERL_SWITCHES} = '';
#$ENV{HARNESS_PERL_SWITCHES} .=' -MDevel::Cover=-db,cover_db,-ignore,.*,-select,' . 'Model_ajax.pm,';
$ENV{HARNESS_PERL_SWITCHES} .=' -MDevel::Cover=-db,cover_db,-ignore,\.t';

print $ENV{HARNESS_PERL_SWITCHES} . "\n";

open my $tap_file, '>', $type . '_test_results.tap' or die "File open error:" . $! ;

my ($total, $failed) = execute_tests(tests => \@tests, out => $tap_file);

close $tap_file;

my $tck;
my $root_path;
my $git_version;

if ( $ENV{ SAVETESTRESULTS } ) {
    $tck = undef ;# TestCaseKPI->new();
    $git_version = $tck->get_version_only();
}
my @passed = subtract(\@tests, [ keys %{$failed} ]);
print_testcases({
    tc_list => [ keys %{$failed} ],
    status  => 'failed',
    color   => 'bold red',
});

print_testcases({
    tc_list => \@passed,
    status  => 'passed',
    color   => 'bold green',
});

if ( $ENV{ SAVETESTRESULTS } ) {
    print_pass_fail_rate();
    stat_to_json();
}

if ( keys %{$failed} ) {
    exit 1;
} else {
    exit 0;
}

sub print_testcases {
    my $conf = shift;
    my $tc_name = '';
    my $tc_path = '';
    for my $act_test(@{$conf->{tc_list}}) {
        $tc_name = $act_test;
        $tc_path = $act_test;
        $tc_path =~s/(\.t)/-pm/;

        if( $conf->{color} =~/green/) {
            $CONSOLE->Attr($FG_GREEN);
        } else {
            $CONSOLE->Attr($FG_RED);
        }

        print $tc_name . " is " . $conf->{status}. "\n";

        $CONSOLE->Attr($attr);


        if ( $tck ) {
            $tck->add_test({
                ResultID       => $conf->{status} =~/passed/ ? $tck->passed() : $tck->failed(),
                TestCaseTypeID => $tck->unit(),
                TestCaseName   => $tc_name,
                VersionName    => $git_version,
                ProjectID      => $tck->voltaire(),
                ResultLink     => $root_path . $tc_path . ".html",
            });
        }
    }
}

sub print_pass_fail_rate {
    my $pass_fail = $tck->get_actual_pass_fail_rate_by_project_tctype({
        ProjectID      => $tck->voltaire(),
        TestCaseTypeID => $tck->unit(),
    });

    for(qw(passed failed)) {
        print "$_: $pass_fail->{stat}->{$_}\n";
    }

    print"rate: ". ($pass_fail->{stat}->{passed} / ($pass_fail->{stat}->{passed} + $pass_fail->{stat}->{failed}) * 100) . "\n";

}

sub subtract {
    my $fst = shift;
    my $scnd = shift;

    my %hash = map{ $fst->[$_] => $_ } 0..$#{$fst};
    delete @hash{@{$scnd}};
    my @rv = sort {$hash{$a} <=> $hash{$b}} keys %hash;
    return @rv; # "return" statement followed by "sort".  Behavior is undefined if called in scalar context.
}

sub stat_to_json {
    $tck->print_stat();
    $tck->print_chart();

}

__END__
