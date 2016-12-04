package Log ;
use strict ;
use warnings ;
use Data::Dumper ;
use File::stat ;
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

sub init {
    my $self = shift ;
    $self->{ 'LOG_DIR' } = $_[ 0 ]->{ "LOG_DIR" } ;
    $self ;
} ## end sub init

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
    my $dir    = ( $self->{ 'LOG_DIR' } ? $self->{ 'LOG_DIR' } : './log/' ) ;
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
