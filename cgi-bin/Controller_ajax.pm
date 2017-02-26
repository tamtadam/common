package Controller_ajax ;

use strict ;
use Data::Dumper ;
use Log ;
use DB_Session ;
use DBConnHandler qw( SESS_REQED NO_SESSION START STOP ) ;

our @ISA ;

sub new {
    my $instance = shift ;
    my $class    = ref $instance || $instance ;
    my $self     = {} ;

    bless $self, $class ;
    my $required_module ;

    ( defined $_[ 0 ]->{ "MODEL" } )
      ? ( $required_module = $_[ 0 ]->{ "MODEL" } )
      : ( $required_module = "Modell_ajax" ) ;

    eval {
        require $required_module . "\.pm" ;
        $required_module->import() ;
        1 ;
      }
      or do {
        print "Module is not found: " . $@ ;
      } ;

    @ISA = ( "Log", $required_module ) ;
    $self->init( @_ ) ;
    $self ;
} ## end sub new

sub init {
    my $self = shift ;
    $self->{ 'DB_Session' } = DB_Session->new( { 'DB_HANDLE' => $_[ 0 ]->{ 'DB_HANDLE' } } ) ;
    $_[ 0 ]->{ 'DB_Session' } = $self->{ 'DB_Session' } ;
    eval '$self->' . "$_" . '::init(@_)' for @ISA ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;

    $self ;
} ## end sub init

sub start_action {
    my $self = shift ;
    #$self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;

    my $received_data = shift ;
    my $uid ;
    my $return_value ;
	
	#$uid = $received_data->{ "session_data" } eq "undef";
	$self->start_time( @{ [ caller( 0 ) ] }[ 3 ], $received_data ) ;
	
	if ( $received_data->{"session_data"} ) {
        $uid = $self->{'DB_Session'}->check_session( $received_data->{'session_data'} );
    }

	$self->start_time( @{ [ caller( 0 ) ] }[ 3 ], $uid ) ;

    for ( sort { $received_data->{ $b }->{ 'order' } <=> $received_data->{ $a }->{ 'order' } }
          grep { not /session_data/ } keys %{ $received_data } )
    {

        if ( ( SESS_REQED() && !NO_SESSION( $_ ) ) && !defined $uid ) {
            $self->add_error( 'SESSIONREQ' )  ;
            return $self->my_die();
        } ## end if ( SESS_REQED( $_ ) )

        if ( 'ARRAY' eq ref $received_data->{ $_ } ) {
            $received_data->{ $_ }->[ 0 ]->{ 'uid' } = $uid ;
        } elsif( 'HASH' eq ref $received_data->{ $_ } ) {
            $received_data->{ $_ }->{ 'uid' } = $uid ;
        } ## end else [ if ( 'ARRAY' eq ref $received_data...)]

        START ;
        delete $received_data->{ $_ }->{ 'order' } if 'HASH' eq ref $received_data->{ $_ };
        $return_value->{ $_ } = $self->$_( $received_data->{ $_ } ) ;
        $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], $return_value ) ;

        $return_value->{ 'time' }->{ $_ } = STOP ;

    } ## end for ( sort { $received_data...})


    $return_value->{ "errors" } = $self->get_errors() ;
    return $return_value ;
} ## end sub start_action


sub my_die {
    my $self = shift;
    my $return_value = {};

    $return_value->{ "errors" } = $self->get_errors() ;

    return $return_value;
}

sub Logout {
   my $self = shift;
   $self->start_time( @{ [ caller(0) ] }[3], \@_ );

   my $data = shift;
   $self->{'DB_Session'}->delete_session( $data->{'session_id'} );

   return {};
}

sub LoginForm {
   my $self = shift;
   my $data = shift;
   my @login = $self->{'DB_Session'}->check_password($data);
      $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@login ) ;
   if ( @login ) {
       my $session = $self->{'DB_Session'}->save_session( { 'login' => $login[ 0 ], } );
       return { map { $_ => $session->{ $_ } } grep { $_ =~/session|username/} keys %{ $session } } ;
   } else {
       return;
   }
}

1 ;
