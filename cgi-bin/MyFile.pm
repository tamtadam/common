package MyFile ;

use Data::Dumper ;

our $VERSION = "1.00" ;

sub new {
    my $instance = shift ;
    my $class    = ref $instance || $instance ;
    my $self     = {} ;

    bless $self, $class ;
    $self ;
} ## end sub new

sub get_file_content {
    my $self = shift ;
    my @result ;
    my $file_name = ( ref $self ? ( $self->get_file_name() ) : ( $self ) ) ;
    open( FILE, $file_name ) or print "File open error: $file_name" and return "" ;
    @result = <FILE> ;
    close FILE ;
    wantarray ? return @result : return join( "", @result ) ;
} ## end sub get_file_content

sub get_file_name {
    my $self = shift ;
    return $self->{ 'FILE_NAME' } ;
} ## end sub get_file_name

sub set_file_name {
    my $self = shift ;
    $self->{ "FILE_NAME" } = shift ;
    $self->empty_content() ;
} ## end sub set_file_name

sub add_content {
    my $self = shift ;
    $self->{ 'file_content' } = "" unless $self->{ 'file_content' } ;
    $self->{ 'file_content' } .= shift ;
} ## end sub add_content

sub empty_content {
    $_[ 0 ]->{ "file_content" } = "" ;
} ## end sub empty_content

sub print_to_file {
    my $self = shift ;
    open( FILE, ">" . $self->{ "FILE_NAME" } ) or print "File open error: $!" and print $self->get_file_name() ;
    print FILE $self->{ 'file_content' } ;
    $self->empty_content() ;
    close FILE ;
} ## end sub print_to_file

1 ;
