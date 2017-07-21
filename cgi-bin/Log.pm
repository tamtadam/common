package Log ;
use strict ;
use warnings ;
use Data::Dumper ;
use File::stat ;
use English qw' -no_match_vars ';

our $LOG_ENABLED = 1 ;
our $LOG_TO_STDOUT = 0 ;
our $VERSION     = '0.02' ;

sub new {
    my ( $class ) = shift ;

    my $self = {} ;
    bless( $self, $class ) ;
    $self->init( @_ ) ;
    return $self ;
} ## end sub new

my $output;
my $outputFH;
my $oldFH;

sub init {
    my $self = shift ;
    my $params = shift || {};
    $self->{ 'LOG_DIR' } = $params->{ "LOG_DIR" } ;

    if ( $params->{ STDOUTREDIR } ) {
        open($outputFH, '>>', $self->get_stdout_log_path() ) or die; # This shouldn't fail
        $| = 1;
        $oldFH = select $outputFH;
    }
    $self ;
} ## end sub init

sub get_stdout_log_path {
    my $self = shift;
    return  ( $OSNAME =~/win/i ? $self->{ "LOG_DIR" } . "//stdout.log" : '/tmp/stdout.log');
}

sub log_info {
    my @params = @_;
    print what_time_is_it() . "   :   " . join("", @params) if $ENV{ ENABLE_STDOUT };
}

sub what_time_is_it {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime ;
    $year += 1900 ;
    $mon  += 1 ;
    return "$year-$mon-$mday $hour:$min:$sec" ;
} ## end sub time_to_db

sub start_time {
    my $self = shift ;

    return undef unless $LOG_ENABLED;

    $_[ 0 ] =~ /(\w+)::(\w+)/i ;
    my $pkg = $1 ;
    my $fv  = $2 ;
    $fv  = "unknown sub" unless $fv ;
    $pkg = "unknown pkg" unless $pkg ;
    my $params = $_[ 1 ] ;
    my $w_mode = ">>" ;
    my $file   = "$pkg" . "_" . "$fv.txt" ;
    my $dir    = ( ref $self && $self->{ 'LOG_DIR' } ? $self->{ 'LOG_DIR' } : './log/' ) ;
    unless ( -e $dir ) {
        mkdir( $dir ) ;
    } ## end unless ( -e $dir )

    my $size = stat( $dir . $file ) ;
    if ( $size and $size->size >= 1000000 ) {
        $w_mode = ">" ;
    } ## end if ( $size and $size->...)
    if ( $ENV{ LOG_TO_STDOUT }) {
        print "\n$pkg" . "::" . "$fv\n start_time: " . ( scalar localtime ) . "\n" ;
        print Dumper $params;
    }
    open( LOGGER, $w_mode . $dir . $file ) or return $fv ;
    print LOGGER "\n$pkg" . "::" . "$fv\n start_time: " . ( scalar localtime ) . "\n" ;
    print LOGGER Dumper $params;
    close LOGGER ;
    return $fv ;
} ## end sub start_time

sub end_time {
    my $self = shift ;
    return undef unless $LOG_ENABLED ;

    $_[ 1 ] =~ /(\w+)::(\w+)/i ;
    my $pkg        = $1 ;
    my $fv         = $2 ;
    my $file       = "$pkg" . "_" . "$fv.txt" ;
    my $start_time = $_[ 0 ] ;
    my $abs        = abs( time - $start_time ) ;

    #print "\n$pkg" . "::" . "$pkg :: $fv\n end_time: " . ( scalar localtime ) . "\n totel run time = $abs\n" ;
} ## end sub end_time

1 ;
