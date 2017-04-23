package Errormsg;
use strict;
use warnings;
use Data::Dumper;

use FindBin;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/cgi-bin/";

our $VERSION = '0.02';

use constant {
    DB_SELECT               => 'DB_SELECT',
    SESSIONREQ              => 'SESSIONREQ',
    FEATURE_NOT_ADDED       => 'FEATURE_NOT_ADDED',
    PARAM_MISSING           => 'PARAM_MISSING',
    PROJECT_EXIST           => 'PROJECT_EXIST',
    LOCKUNLOCK              => 'LOCKUNLOCK'
};

my $ERROR_CODES = {
    "DB_SELECT"                => "Selection from db. does not response",
    "SESSIONREQ"               => "You are not logged in",
    "FEATURE_NOT_ADDED"        => "It's not possible to add this feature",
    "PARAM_MISSING"            => "Parameter is missing",
    "PROJECT_EXIST"            => "This project name is already exist",
    "LOCKUNLOCK"               => "Lock/Unlock failure"
} ;

sub new {
    my ($class) = shift;

    my $self = {};

    bless( $self, $class );
    $self->init;
    return $self;
}

sub init {
    my $self = shift;
    $self->{ 'ERROR_CODES' } = [] ;
    $self->{ 'TIMES' } = [] ;
    $self;
}

sub add_error{
    my $self = shift ;
    push @{ $self->{ 'ERROR_CODES' } }, $self->get_error_text( shift ) ;
}


sub get_error_text{
    my $self = shift ;
    my $error_id = shift ;

    if ( defined $ERROR_CODES->{ $error_id } ){
        return $ERROR_CODES->{ $error_id } ;
    } else {
        return "$error_id does not found" ;
    }
}

sub get_errors{
    my $self = shift ;
    return $self->{ 'ERROR_CODES' } || {};
}

sub empty_errors{
    my $self = shift ;
    $self->{ 'ERROR_CODES' } = [] ;

}

1;