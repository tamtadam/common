package View_ajax ;

use strict ;
use Data::Dumper ;

use FindBin ;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/cgi-bin/" ;

use Ajax ;
use Log ;
use JSON ;
our @ISA = qw( Log Ajax ) ;

my $log = 1 ;

sub new {
    my $instance = shift ;
    my $class    = ref $instance || $instance ;
    my $self     = {} ;

    bless $self, $class ;
    return $self->init( @_ ) ;
} ## end sub new

sub init {
    my $self = shift ;
    eval '$self->' . "$_" . '::init(@_)' for @ISA ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) if $log ;

    $self ;
} ## end sub init

sub send_data_to_server {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) if $log ;

    my $data        = shift ;
    my $encode_type = "JSON" ;
    my $send_data ;
    if ( "JSON" eq $encode_type ) {

        return undef if ( 'SCALAR' eq ref $data ) ;
        return undef unless ref $data ;
        $send_data = JSON->new->allow_nonref->encode( $data ) ;

        $self->sendResultToClient( $send_data ) ;
    } ## end if ( "JSON" eq $encode_type)
} ## end sub send_data_to_server

sub get_data_from_server {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) if $log ;

    my $needed_param = shift ;

    my $needed_valus = $self->getDataFromClient( $needed_param );
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], $needed_valus ) if $log ;
    return $needed_valus ;
} ## end sub get_data_from_server

1 ;

