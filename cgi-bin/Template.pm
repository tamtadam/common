package Template;

use 5.010001;
use strict;
use warnings;
use MyFile  ;
use base 'Exporter'; 
our $VERSION = '0.04';

use constant TYPE => {
    "FILE"       => "FILE",
    "ARRAY"      => "ARRAY",
    "FILEHANDLE" => "FILEHANDLE",
    "STRING"     => "STRING",
} ;

our @EXPORT_OK = qw( TYPE );

# TYPE => 'FILE',        SOURCE => 'filename.tmpl
# TYPE => 'ARRAY',       
# TYPE => 'FILEHANDLE',  
# TYPE => 'STRING',      
sub new {
    my $instance = shift;
    my $class    = ref $instance || $instance;
    my $self     = {};
    
    bless $self, $class;
    $self->init( @_ ) ;
    $self;
}

sub init{
    my $self = shift ;
    $self->{ "TEMPLATE" } = "" ;
    
    if( $_[ 0 ]->{ 'TYPE' } eq TYPE->{ FILE } ){
        $self->{ "TEMPLATE" } = &MyFile::get_file_content( $_[ 0 ]->{ 'SOURCE' } ) ;
            
    } elsif( $_[ 0 ]->{ 'TYPE' } eq TYPE->{ STRING } ){
        $self->{ "TEMPLATE" } = $_[ 0 ]->{ 'SOURCE' } ;
    }
    return $self ;
}

sub change_source {
    my $self = shift;
    $self->{ "TEMPLATE" } = shift // '';
}

sub fill_in{
    my $self = shift ;

    unless( defined $self->{ 'STRING' } ){
        $self->{ 'STRING' } = $self->{ 'TEMPLATE' } ;
    }

    foreach my $repl ( keys %{ $_[ 0 ] } ){
        if ( ref $_[ 0 ]->{ $repl } eq 'ARRAY' ){
            $_ and $self->{ 'STRING' } =~s/$repl/$_/s foreach @{ $_[ 0 ]->{ $repl } } ;
        } else {
            $self->{ 'STRING' } =~s/$repl/$_[ 0 ]->{ $repl }/gs ;
        }
    }
}

sub switch_to_orig{
    my $self = shift ;
    delete $self->{ 'STRING' } if defined $self->{ 'STRING' } ;

}

sub return_string{
    my $self = shift ;
    if ( defined $self->{ 'STRING' } ){
        return $self->{ 'STRING' } ;
    } else {
        return $self->{ 'TEMPLATE' } ;
    }

}


1;

