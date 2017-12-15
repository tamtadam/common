#!/usr/bin/perl

use strict;
use warnings;
use DBConnHandler;
use CGI;
use View_ajax;
use Controller_ajax;
use Data::Dumper ;
use English qw' -no_match_vars ';

$ENV{ STDOUT_REDIRECT } = 0;
Log::init_log_path( $OSNAME =~/win/i ? "f:\\xampp\\cgi-bin\\log\\" : "/var/www/cgi-bin/log/" );

my $cfg = ( $OSNAME =~/win/i ? '' : '/var/www/cgi-bin/' ) . 'server.cfg' ;

my $db = &DBConnHandler::init( $cfg );

my $ajax       = View_ajax->new()      ;
my $controller = Controller_ajax->new( {
                                        'DB_HANDLE' => $db ,
                                        #'MODEL'     => "ontozo_model",
} );

my $struct;
my $data;

$data = $ajax->get_data_from_server();

$struct = $controller->start_action( $data );
$ajax->send_data_to_server( $struct, "JSON" );
