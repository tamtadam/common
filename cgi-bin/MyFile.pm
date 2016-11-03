package MyFile;

use Data::Dumper ;

our $VERSION = "1.00";

sub new{
    my $instance = shift;
    my $class    = ref $instance || $instance;
    my $self     = {};

    bless $self, $class;
    $self;
}

sub get_file_content{
    my $self = shift ;
    my @result ;
    my $file_name = (ref $self ? ( $self->get_file_name() ) : ( $self ) ) ;
    open ( FILE, $file_name ) or print "File open error: $file_name" and return "" ;
    @result = <FILE> ;
    close FILE ;
    wantarray ? return @result : return join( "",@result ) ;
}

sub get_file_name{
    my $self = shift ;
    return $self->{ 'FILE_NAME' };
}

sub set_file_name{
    my $self = shift ;
    $self->{ "FILE_NAME" } = shift;
    $self->empty_content() ;
}

sub add_content{
    my $self = shift ;
    $self->{ 'file_content' } = "" unless $self->{ 'file_content' } ;
    $self->{ 'file_content' } .= shift ;
}

sub empty_content{
    $_[ 0 ]->{ "file_content" } = "" ;
}

sub print_to_file{
    my $self = shift ;
    open ( FILE, ">" . $self->{ "FILE_NAME" } ) or print "File open error: $!" and print $self->get_file_name();
    print FILE $self->{ 'file_content' } ;
    $self->empty_content();
    close FILE ;
}

1;