package params;
use strict;
use Data::Dumper;
use OBJECTS;
use Exporter;
our $VERSION = '0.02';
our @ISA = qw( OBJECTS ) ;
use vars qw ( $AUTOLOAD );
our @EXPORT_OK = qw(run_status);

our $params;

sub init_params {
    my $self = shift;
    return $params //= $self->load_ids_from_table();
}

sub load_ids_from_table {
    my $self = shift;
    $params = {};

    unless ( scalar keys %{ $params } ) {
        my $db_data = $self->my_select({
                 'from'   => 'params',
                 'select' => 'ALL',
        });
        bless( $params, 'OBJECTS' );
        foreach my $row ( @{$db_data} ) {
            $params->add_autoload_method( uc $row->{'name'}, $row->{'params_id'} );
        }
    }
    return $params;
}


1;