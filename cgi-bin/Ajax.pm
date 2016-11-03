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
    for ( $self->{CGI}->param() ) {
        my $json = JSON->new->allow_nonref;
        next unless  $self->{CGI}->param($_) ;
        $result->{$_} = $json->utf8(0)->decode ($self->{CGI}->param($_));#, { utf8  => 1 } );
        $true = 1  ;
    }
    return $result;
}

sub sendResultToClient {
    my $self = shift;
    my $data = shift;

    print Encode::encode_utf8($data) ;
}

1;

