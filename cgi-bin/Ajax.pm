package Ajax;
use strict;
use warnings;
use CGI;
use Data::Dumper;
use utf8;
use JSON;
use Encode qw(decode encode);
our @ISA = qw();
sub new {
    my ($class) = shift;

    my $self = {};

    bless( $self, $class );
    $self->init;
    return $self;
}

sub init {
    my $self = shift;
    eval '$self->' . "$_" . '::init( @_ )' for @ISA;
    $self->{CGI} = CGI->new();
    print $self->{CGI}->header(-type=>"text/html",-charset=>"utf-8");

    $self;
}

sub getDataFromClient {
    my $self   = shift;
    my $data   = shift;
    my $result = {};

    my $true = undef ;

    $CGI::LIST_CONTEXT_WARN = 0;
    my $json = JSON->new->allow_nonref;
    for ( $self->{CGI}->param() ) {
        next unless  $self->{CGI}->param($_) ;
        $result->{$_} = $json->utf8(0)->decode ($self->{CGI}->param($_));#, { utf8  => 1 } );
        $true = 1  ;
    }
    if( $ARGV[ 0 ] ) {
        $result = $json->utf8(0)->decode( $ARGV[ 0 ] );
        $true = 1  ;
    }
    return $result;
}

sub sendResultToClient {
    my $self = shift;
    my $data = shift;

    print Encode::encode_utf8($data) ;
}

=pod

See Microsoft KB article STDIN/STDOUT Redirection May Not Work If Started from a File Association:

Start Registry Editor.
Locate and then click the following key in the registry: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
On the Edit menu, click Add Value, and then add the following registry value:
Value name: InheritConsoleHandles
Data type: REG_DWORD
Radix: Decimal
Value data: 1
Quit Registry Editor.

=cut
1;

