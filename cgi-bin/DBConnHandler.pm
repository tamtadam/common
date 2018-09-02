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
use MyFile;
use Time::HiRes qw(time) ;
@EXPORT_OK = qw( $DB $SERVER_CFG SESS_REQED SEL_CSET INS_CSET GET_FUNC_NAME START STOP INS_COLLAT NO_SESSION ) ;

our $SLESH      = $^O =~ /win/i ? '\\' : '/' ;
our $QSLESH     = quotemeta $SLESH ;
our $DB         = undef ;
our $SERVER_CFG = {} ;
our $start_time = undef ;

BEGIN {
    use strict ;
} ## end BEGIN

sub disconnect {
    $DB->disconnect() if $DB ;
}

END {
    $DB->disconnect() if $DB ;
} ## end END

sub init {
    my $project_cfg = shift ;

    $SERVER_CFG->{ my_sql } = ( $project_cfg and -e $project_cfg ? Cfg::get_struct_from_file( $project_cfg )->{ DATABASE } : {} ) ;

    $DB = DBI->connect(
                        @{ get_data_src() },
                        {
                           RaiseError => 1,
                           PrintWarn  => 0,
                           PrintError => 0
                        }
                      )
        or print "ERROR in db connection\n" . Dumper ( $SERVER_CFG->{ my_sql } || $ENV{ TEST_SQLITE } );
    
    if ( $ENV{ TEST_SQLITE } and $ENV{ TEST_SQLITE } =~ /:memory:/ ) {
        $DB->sqlite_backup_from_file($ENV{DATABASE});
    }
    return $DB ;
} ## end sub init

sub init_sqlite_db {
    my @tables = @_ ;
    my $sql;
    for my $table ( @tables ) {
        $sql = MyFile::get_file_content( $table );
        my $gth = $DB->prepare( $sql );
        $gth->execute();
    }
}

sub get_data_src {
    return ( get_test_data_src() or get_normal_data_src() ) ;
} ## end sub get_data_src

sub get_test_data_src {
    my $test_env = $ENV{ TEST_SQLITE } || return ;
    return [ 'dbi:SQLite:dbname=' . $test_env, "", "" ] ;
} ## end sub get_test_data_src

sub get_normal_data_src {
    my $cfg = get_my_sql_config() ;
    return [ "dbi:$cfg->{PLATFORM}:dbname=$cfg->{DATABASE};host=$cfg->{HOST};port=$cfg->{PORT};",
             "$cfg->{USER}", "$cfg->{PWD}" ] ;
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
    return get_my_sql_config()->{ SESSION };
} ## end sub SESS_REQED

sub NO_SESSION {
    return !get_my_sql_config()->{ $_[ 0 ] }{ SESSION };
}

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
