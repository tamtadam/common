package DBConnHandler ;

use FindBin ;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/cgi-bin/" ;

use Log ;
use DBI ;
use Cfg ;
use Carp ;
use Exporter 'import' ;
use Data::Dumper ;
use Time::HiRes qw(time) ;
@EXPORT_OK = qw( $DB $SERVER_CFG SESS_REQED SEL_CSET INS_CSET GET_FUNC_NAME START STOP INS_COLLAT ) ;

our $SLESH      = $^O =~ /win/i ? '\\' : '/' ;
our $QSLESH     = quotemeta $SLESH ;
our $DB         = {} ;
our $SERVER_CFG = {} ;
our $start_time = undef ;

BEGIN {
    use strict ;
} ## end BEGIN

END {
    $DB->disconnect() ;
} ## end END

sub init {
    my $project_cfg = shift ;

    $SERVER_CFG->{ my_sql } = Cfg::get_struct_from_file( $project_cfg )->{ DATABASE } ;

    $DB = DBI->connect(
                        get_data_src(),
                        {
                           RaiseError => 1,
                           PrintWarn  => 0,
                           PrintError => 0
                        }
                      )
      or print "ERROR in db connection\n" . Dumper $SERVER_CFG->{ my_sql } ;
    return $DB ;
} ## end sub init

sub get_data_src {
    return get_test_data_src() || get_normal_data_src() ;
} ## end sub get_data_src

sub get_test_data_src {
    my $test_env = $ENV{ TEST_SQLITE } || return ;

    return 'dbi:SQLite::dbname=' . $test_env ;
} ## end sub get_test_data_src

sub get_normal_data_src {
    my $cfg = get_my_sql_config() ;
    return ( "dbi:$cfg->{PLATFORM}:dbname=$cfg->{DATABASE};host=$cfg->{HOST};port=$cfg->{PORT};",
             "$cfg->{USER}", "$cfg->{PWD}" ) ;
} ## end sub get_normal_data_src

sub get_my_sql_config {
    return $SERVER_CFG->{ my_sql } || {} ;
} ## end sub get_my_sql_config

sub my_sql {
    $DB->{ my_sql } || confess 'NO my_sql db connected' ;
} ## end sub my_sql

sub sqlite {
    $DB->{ sqlite } || confess 'NO sqlite db connected' ;
} ## end sub sqlite

sub START {
    $start_time = time ;
} ## end sub START

sub STOP {
    my $stop_time = time ;

    $stop_time -= $start_time ;
    return int( ( $stop_time * 1000 ) ) / 1000 ;

} ## end sub STOP

sub SESS_REQED {
    return $SERVER_CFG->{ my_sql }{ 'PREREQ' }->{ $_[ 0 ] }->{ 'SESSION' } ;
} ## end sub SESS_REQED

sub SEL_CSET {
    return $SERVER_CFG->{ my_sql }{ 'PREREQ' }->{ $_[ 0 ] }->{ 'CHARSET' }->{ 'SELECT' } ;

} ## end sub SEL_CSET

sub INS_CSET {
    return $SERVER_CFG->{ my_sql }{ 'PREREQ' }->{ $_[ 0 ] }->{ 'CHARSET' }->{ 'INSERT' } ;

} ## end sub INS_CSET

sub INS_COLLAT {
    return $SERVER_CFG->{ my_sql }{ 'PREREQ' }->{ $_[ 0 ] }->{ 'CHARSET' }->{ 'COLLAT' } ;

} ## end sub INS_COLLAT

sub GET_FUNC_NAME {

    @{ [ caller( 1 ) ] }[ 3 ] =~ /(\w+)::(\w+)/i ;

    return $2 ;
} ## end sub GET_FUNC_NAME

1 ;
