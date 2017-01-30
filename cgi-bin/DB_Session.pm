package DB_Session;

use strict;
use warnings;
use utf8;
use Data::Dumper;
use DBH;

use FindBin;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/cgi-bin/";

use DBI ;
use CGI::Session qw/-ip-match/;
use Log ;

my $struct;
my $data;

our @ISA = qw( Log DBH );

sub new {
    my ($class) = shift;

    my $self = {};

    bless( $self, $class );
    $self->init( @_ );
    return $self;
}

sub init{
    my $self = shift ;
    $self->{'DB'} = $_[0]->{'DB_HANDLE'} ;
    return $self ;
}

sub check_password{
    my $self = shift ;
    my $data = shift ;

    my $loginn = $data->{'acc'};
    my $passwdd= $data->{'pwd'};
    #$context->add($passwdd);
    my @login = $self->my_select({
        from => 'partner',
        where => {
            username  => $data->{'acc'},
            password  => $data->{'pwd'},
            activated => 1
        },
    });	
    return @login;
}

sub check_session {
    my $self = shift ;
    my $data   = shift ;
    my $IP     = $ENV{'REMOTE_ADDR'}    ;
    my $session_id = $data->{'session'} ;
    my $nick       = $data->{'nick'}    ;

    return undef unless defined $session_id  ;
    $self->{'Session'} = new CGI::Session("driver:MySQL", $session_id,  {Handle=>$self->{'DB'} }) or print "error";


    if( $self->{'Session'}->id() ne $session_id or $self->{'Session'}->is_expired() ) {

        $self->delete_session( $session_id ) ;
        $self->{'Session'}->delete();
        undef(  $self->{'Session'} ) ;
        return undef ;
    }

    if( my $uid = $self->{'Session'}->param('partner_id') ){

        $data->{'pacient_id'} ? return $data->{'pacient_id'} : return $uid ;
    } else {
        return undef ;
    }

}

sub save_session{
    my $self   = shift ;
    my $login  = $_[0]->{'login'}    ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], $login ) ;

    my $IP     = $ENV{'REMOTE_ADDR'} ;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    $year=$year+1900;
    $mon++ ;
    $self->{'Session'} = new CGI::Session("driver:MySQL", undef,  {Handle=>$self->{'DB'} }) or print "error";
	
    return undef unless defined $login->{'username'};
    
    $self->{'Session'}->param('partner_id',$login->{'partner_id'});
    $self->{'Session'}->param('nick',$login->{'login_nev'});
    $self->{'Session'}->param('logged_in',1);
    $self->{'Session'}->param('ip_addr',$IP);
    $self->{'Session'}->param('conn_time',"$year-$mon-$mday $hour:$min");
    $self->{'Session'}->expire('+5h');
    my $session_id = $self->{'Session'}->id();
 
    return undef unless defined $session_id ;
    $login->{'session'} = $session_id ;
    $login->{'nick'} = $login->{'username'};
    my $sth    = $self->{'DB'} -> prepare("UPDATE sessions SET expire = TIMESTAMPADD(MINUTE,1440,NOW()) where id=?") ;
    $sth->execute( $session_id ) or die "ERROR\n";
    $sth    = $self->{'DB'} -> prepare("UPDATE sessions SET pid = ? where id=?") ;
    $sth->execute( $login->{'partner_id'}, $session_id ) or die "ERROR\n";

    return $login  ;
}

sub delete_session{
    my $self       = shift ;
    my $session_id = shift ;

    $self->start_time( @{ [ caller(0) ] }[3], $session_id ) ;
    $self->{'Session'} = new CGI::Session("driver:MySQL", $session_id,  {Handle=>$self->{'DB'} }) or print "error";

    my $sth    = $self->{'DB'} -> prepare("DELETE FROM sessions WHERE id=?") ;
    $sth->execute( $session_id );
    $sth    = $self->{'DB'} -> prepare("DELETE from sessions where TIMESTAMPDIFF(MINUTE, NOW(),expire) < -1440;") ;
    $sth->execute( ) or die "ERROR\n";
    $self->{'Session'}->delete();
}

    1;