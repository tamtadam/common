#!C:\Perl64\bin\perl.exe

use strict;
use warnings;

use FindBin ;

use lib 'f:\\GIT\\common\\cgi-bin\\';
use lib 'f:\\GIT\\gherkin_editor\\cgi-bin\\';

use DBConnHandler;
use CGI;
use View_ajax;
use Controller_ajax;
use Data::Dumper ;
use English qw' -no_match_vars ';

Log::init_log_path( $OSNAME =~/win/i ? "./log/" : "/var/www/cgi-bin/log/" );


$ENV{ STDOUT_REDIRECT } = 0;

my $db = &DBConnHandler::init( "server.cfg" );

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
