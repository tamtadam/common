package Template ;

use 5.010001 ;
use strict ;
use warnings ;

use FindBin ;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/cgi-bin/" ;

use MyFile ;
use base 'Exporter' ;
our $VERSION = '0.04' ;

use constant TYPE => {
                       "FILE"       => "FILE",
                       "ARRAY"      => "ARRAY",
                       "FILEHANDLE" => "FILEHANDLE",
                       "STRING"     => "STRING",
                     } ;

our @EXPORT_OK = qw( TYPE ) ;

# TYPE => 'FILE',        SOURCE => 'filename.tmpl
# TYPE => 'ARRAY',
# TYPE => 'FILEHANDLE',
# TYPE => 'STRING',
sub new {
    my $instance = shift ;
    my $class    = ref $instance || $instance ;
    my $self     = {} ;

    bless $self, $class ;
    $self->init( @_ ) ;
    $self ;
} ## end sub new

sub init {
    my $self = shift ;
    $self->{ "TEMPLATE" } = "" ;

    if ( $_[ 0 ]->{ 'TYPE' } eq TYPE->{ FILE } ) {
        $self->{ "TEMPLATE" } = &MyFile::get_file_content( $_[ 0 ]->{ 'SOURCE' } ) ;

    } elsif ( $_[ 0 ]->{ 'TYPE' } eq TYPE->{ STRING } ) {
        $self->{ "TEMPLATE" } = $_[ 0 ]->{ 'SOURCE' } ;
    } ## end elsif ( $_[ 0 ]->{ 'TYPE'...})
    return $self ;
} ## end sub init

sub change_source {
    my $self = shift ;
    delete $self->{ STRING } ;
    $self->{ "TEMPLATE" } = shift // '' ;
} ## end sub change_source

sub fill_in {
    my $self = shift ;

    unless ( defined $self->{ 'STRING' } ) {
        $self->{ 'STRING' } = $self->{ 'TEMPLATE' } ;
    } ## end unless ( defined $self->{ ...})

    foreach my $repl ( keys %{ $_[ 0 ] } ) {
        if ( ref $_[ 0 ]->{ $repl } eq 'ARRAY' ) {
            $_ and $self->{ 'STRING' } =~ s/$repl/$_/s foreach @{ $_[ 0 ]->{ $repl } } ;
        } else {
            $self->{ 'STRING' } =~ s/$repl/$_[ 0 ]->{ $repl }/gs ;
        } ## end else [ if ( ref $_[ 0 ]->{ $repl...})]
    } ## end foreach my $repl ( keys %{ ...})
} ## end sub fill_in

sub switch_to_orig {
    my $self = shift ;
    delete $self->{ 'STRING' } if defined $self->{ 'STRING' } ;

} ## end sub switch_to_orig

sub return_string {
    my $self = shift ;
    if ( defined $self->{ 'STRING' } ) {
        return $self->{ 'STRING' } ;
    } else {
        return $self->{ 'TEMPLATE' } ;
    } ## end else [ if ( defined $self->{ ...})]

} ## end sub return_string

1 ;

