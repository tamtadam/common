package Email ;

use FindBin ;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/cgi-bin/" ;

use Log ;
use Cfg ;
use Log ;
use Carp ;
use Data::Dumper ;
use Email::Send::SMTP::Gmail;

our $SLESH      = $^O =~ /win/i ? '\\' : '/' ;
our $QSLESH     = quotemeta $SLESH ;
our $DB         = undef ;
our $CFG        = {} ;
our $start_time = undef ;

BEGIN {
    use strict ;
} ## end BEGIN

sub disconnect {
}

END {
} ## end END

sub init {
    my $project_cfg = shift ;

    $CFG = ( $project_cfg ? Cfg::get_struct_from_file( $project_cfg )->{ DATABASE } : {} ) ;
} ## end sub init

sub send_mail {
    my $params = shift || {};
    Log->start_time('Email::send_mail', { asfasdf => $params} );
    my $mail = Email::Send::SMTP::Gmail->new(
                                             -smtp  => Cfg::get_data('EMAILSMTP'),
                                             -login => Cfg::get_data('EMAILU'),
                                             -pass  => Cfg::get_data('EMAILW'),
                                             -layer => 'ssl',
                                             -port  => 465);
    $mail->send( map { '-' . $_ => $params->{ $_ } } qw(to subject body contenttype) );

    $mail->bye;
}

1 ;
