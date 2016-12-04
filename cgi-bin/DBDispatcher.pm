package DBDispatcher ;

use strict ;
use warnings ;
use Data::Dumper ;

use feature qw( state ) ;

use Exporter qw(import) ;
our @EXPORT_OK = qw(
  convert_sql
  ) ;

my $PARAM_DELIMITER = "###";

# 'PROBA{STRINGIFY100{1, 2, 3   }, PROBAK{1,2}}'
sub convert_sql {
    my $meta_sql = shift;

    $meta_sql =~/(.*?(([A-Z]+\d*_*)+\s*\{(.*)\})\s*),*/;
    my $func = $3;
    my $params = $4;
    return $meta_sql if !defined $3 || !defined $4;

    my @params;
    if( $params =~/\{.*\}/) {
        my $in  = 0;
        my $out = 0;
        my $str = '';
        while( $params =~/(.)/g ) {
            my $act = $1;
            next if $act eq ',' and !$str; # avoid ,2 parameter
            if( $act =~/\{/) {
                $in++
            }
            if( $act =~/\}/) {
                $out++;
            }
            $str .= $act;
            if( $in == $out && $in != 0 && $out != 0 ) {
                push @params, $str;
                $str = '';
                $out = $in = 0;
            }
        }
        push @params, $str if $str;
        @params = map { convert_sql( $_ ) } @params;
    }

    return dispatcher( get_driver(), $func, @params ? @params : split ',', $params );
}

sub _convert_sql {
    my $meta_sql = shift ;

    my $func   = get_key( $meta_sql ) || return $meta_sql;
    my @params = get_params( $meta_sql ) ;
    my $driver = get_driver();

    return dispatcher($driver, $func, @params);
} ## end sub convert_sql

sub get_driver {
    my $driver = 'my_sql' ;

    if ( $ENV{ TEST_SQLITE } ) {
        $driver = 'sqlite' ;
    } ## end if ( $ENV{ TEST_SQLITE...})

    return $driver ;
} ## end sub get_driver

sub get_params {
    my $meta_sql = shift ;

    $meta_sql =~ /\{(.*?)\}/ ;

    return split( '$PARAM_DELIMITER', $1 ) ;
} ## end sub get_params

sub get_key {
    my $meta_sql = shift ;

    $meta_sql =~ /(.*?)\s*\{/ ;

    return $1 ;
} ## end sub get_key

sub dispatcher {
    my $driver = shift ;
    my $func   = shift ;
    my @params = @_    ;

    state $disp = {
        STRINGIFY100 => {
            my_sql => sub { return 'CONVERT(' . $_[ 0 ] . ', CHAR(50))' ;},
            sqlite => sub { return 'CAST(' . $_[ 0 ] . ' as text'; },
        },
        SQLSAFEUPDATES => {
            my_sql => sub { return "SET SQL_SAFE_UPDATES = " . $_[ 0 ] ;},
            sqlite => sub { return "" },
        },
        NOW => {
            my_sql => sub { return "NOW()";},
            sqlite => sub { return "datetime('now',  'localtime')"; },
        }
    } ;

    return $disp->{ $func }{ $driver }( @params );
} ## end sub dispatcher

1 ;
