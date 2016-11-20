#!C:\Perl64\bin\perl.exe

use strict;
use warnings;
use DBConnHandler;
use CGI;
use View_ajax;
use Controller_ajax;
use Data::Dumper ;

my $db = &DBConnHandler::init( "server.cfg" );

my $ajax       = View_ajax->new()      ;
my $controller = Controller_ajax->new( {
                                        'DB_HANDLE' => $db ,
                                        #'MODEL'     => "ontozo_model",
                                        'LOG_DIR'   => "/log/",
} );

my $struct;
my $data;

$data = $ajax->get_data_from_server();

$struct = $controller->start_action( $data );
$ajax->send_data_to_server( $struct, "JSON" );
