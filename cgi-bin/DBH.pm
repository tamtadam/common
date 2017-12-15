package DBH ;

use strict ;
use strict 'subs' ;
use utf8 ;

use Carp ;
use Data::Dumper ;

use FindBin ;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "/cgi-bin/" ;

use Log ;
use Errormsg ;
use params ;
our @ISA = qw( Log Errormsg params ) ;
use DBConnHandler qw( $DB ) ;
our $VERSION = '1.00' ;

#my $dumper = HTML::Table->new ( { DUMPER => 'dumper.html'} );
sub new {
    my $instance = shift ;
    my $class    = ref $instance || $instance ;
    my $self     = {} ;

    bless $self, $class ;
    $self->init( @_ ) ;
    $self->{ 'DB_HANDLE' } = $DB if $DB and !defined $self->{ 'DB_HANDLE' } ;
    $self ;
} ## end sub new

my $PARAM_DELIMITER = "--------" ;

sub init {

    my $self = shift ;
    eval '$self->' . "$_" . '::init( @_ )' for @ISA ;

    $self->{ 'DB_HANDLE' } = $_[ 0 ]->{ 'DB_HANDLE' } ;
    $self->{ 'db_params_by_id' } = $self->init_params();
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    $self ;
} ## end sub init

sub db_params {
    my $self = shift;

    return $self->{ 'db_params_by_id' };
}

sub time_to_db {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime ;
    $year += 1900 ;
    $mon  += 1 ;
    return "$year-$mon-$mday $hour:$min:$sec" ;
} ## end sub time_to_db

sub my_insert {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    $self->{ 'DB_HANDLE' } = $DB if $DB and !defined $self->{ 'DB_HANDLE' } ;
    my $select_data = {} ;
    my $data        = shift ;
    my $field_value = {} ;
    my $table       = $data->{ 'table' } ;
    my $id ;

    my $fields        = $self->create_insert_field_list( $data ) ;
    my $question_mark = $self->create_question_mark_list( $data ) ;
    my @array         = $self->create_param_list( $data ) ;

    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], "INSERT INTO $table ( $fields ) VALUES ( $question_mark )" ) ;
    my $gth = $self->{ 'DB_HANDLE' }->prepare( "INSERT INTO $table ( $fields ) VALUES ( $question_mark )" ) ;

    #print Dumper "INSERT INTO $table ( $fields ) VALUES ( $question_mark )" ;
    #print Dumper @array  ;
    #<>;
    if ( $gth ) {
        my $res ;
        $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@array ) ;
        eval {
            $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@array ) ;
            $res = $gth->execute( @array ) ;
        } ;
        if ( $@ ) {
            if ( $@ =~ /Duplicate entry \'(.*?)\' for key \'(.*?)_UNIQUE\'/ ) {
                $select_data                      = $data ;
                $select_data->{ "where" }->{ $2 } = $1 ;
                $select_data->{ "from" }          = $data->{ "table" } ;
                my $res = $self->my_select( $select_data ) ;
                return $res ;
            } else {
                $self->add_error( 'DB_ERROR', $@ );
                return;
            } ## end else [ if ( $@ =~ /Duplicate entry \'(.*?)\' for key \'(.*?)_UNIQUE\'/)]
        } ## end if ( $@ )

        $res ? ( return $self->my_last_insert_id( $table ) ) : ( undef ) ;

    } else {
        return ;
    } ## end else [ if ( $gth ) ]

} ## end sub my_insert

sub my_update {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    $self->{ 'DB_HANDLE' } = $DB if $DB and !defined $self->{ 'DB_HANDLE' } ;

    my $data = shift ;

    my $table  = $data->{ table } ;
    my $return = undef ;
    my $params ;
    my $where_cl ;

    if ( defined $data->{ 'where_param' } ) {
        $params   = $data->{ 'where_param' } ;
        $where_cl = $data->{ 'where' } ;
    } else {
        ( $params, $where_cl ) = $self->create_where_param( $data ) ;
    } ## end else [ if ( defined $data->{ ...})]
    my $field = @{ [ keys %{ $data->{ update } } ] }[ 0 ] ;

    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], "UPDATE $table SET $field = ? $where_cl" ) ;

    my $gth = $self->{ 'DB_HANDLE' }->prepare( "UPDATE $table SET $field = ? $where_cl" ) ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], "UPDATE $table SET $field = ? $where_cl" ) ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], [ $data->{ 'update' }->{ $field }, $params ] ) ;
    my $res;
    eval {
        $res = $gth->execute( $data->{ 'update' }->{ $field }, @{ [ split( $PARAM_DELIMITER, $params ) ] } ) ;
    };

    if ( $@ ) {
        $self->add_error( 'DB_ERROR', $@ );
        return;
    } else {
    	return $self->my_select({
    		where => $data->{ 'where' },
    		from  => $data->{ 'table' },
    	});
    } ## end if ( $@ )

} ## end sub my_update

sub my_call {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    my $data = shift ;

    my $return = [] ;

    my $question_marks = $self->create_question_mark_list( $data ) ;
    my @params         = $self->create_param_list( $data ) ;
    my $res ;
    my $gth = $self->{ 'DB_HANDLE' }->prepare( "CALL $data->{function}( $question_marks )" ) ;

    if ( $gth ) {
        $res = $gth->execute( @params ) ;
        return undef unless $res ;

        while ( $res = $gth->fetchrow_hashref() ) {
            if ( wantarray ) {
                push @{ $return }, $res->{ $data->{ 'select' } } ;
            } else {
                push @{ $return }, $res ;
            } ## end else [ if ( wantarray ) ]
        } ## end while ( $res = $gth->fetchrow_hashref...)
    } else {
        return undef ;
    } ## end else [ if ( $gth ) ]

    return undef if scalar @{ $return } == 0 and !wantarray ;
    if ( wantarray ) {
        return @{ $return } ;
    } else {
        return $return ;
    } ## end else [ if ( wantarray ) ]
} ## end sub my_call

sub my_select {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    $self->{ 'DB_HANDLE' } = $DB if $DB and !defined $self->{ 'DB_HANDLE' } ;
    return undef if $self->{ 'DB_HANDLE' } == 1 ;
    my $data = shift ;

    #print Dumper $data ;
    my $return = [] ;

    #open( OUT, ">>/home/deveushu/web_log/log/my_select.txt" );
    my $table  = $data->{ from } ;
    my $fields = $self->create_select_field_list( $data ) ;

    my ( $params, $where_cl ) ;

    if ( defined $data->{ 'where_param' } ) {
        $params   = $data->{ 'where_param' } ;
        $where_cl = $data->{ 'where' } ;
    } else {
        ( $params, $where_cl ) = $self->create_where_param( $data ) ;
    } ## end else [ if ( defined $data->{ ...})]

    my $sort_closure = ( $data->{ 'sort' }     ? "ORDER BY $data->{sort}"     : "" ) ;
    my $groupby      = ( $data->{ 'group_by' } ? "GROUP BY $data->{group_by}" : "" ) ;
    my $join         = ( $data->{ 'join' }     ? "$data->{join}"              : "" ) ;
    my $distinct_cl  = ( $data->{ 'distinct' } ? "DISTINCT"                   : "" ) ;
    my $format       = ( $data->{ 'format' }   ? "$data->{format}"            : "" ) ;
    my $limit        = ( $data->{ 'limit' }    ? "LIMIT $data->{limit}"       : "" ) ;

    #print "SELECT $fields FROM $table $where_cl, $params\n ";
    $fields = $format if $format ne "" ;

    #print Dumper "SELECT $distinct_cl $fields FROM $table $join $where_cl $sort_closure $groupby $limit";

#print Dumper "command : SELECT $distinct_cl $fields FROM $table $where_cl $sort_closure  " , [ split( $PARAM_DELIMITER, $params ) ];
#print Dumper "SELECT $distinct_cl $fields FROM $table $join $where_cl $sort_closure $groupby $limit";
#print Dumper $params ;
#print Dumper $self->{DB_HANDLE} ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ],
                       "SELECT $distinct_cl $fields FROM $table $join $where_cl $sort_closure $groupby $limit" ) ;
    my $gth = $self->{ DB_HANDLE }
      ->prepare( "SELECT $distinct_cl $fields FROM $table $join $where_cl  $groupby $sort_closure $limit" ) ;

#print OUT "\n";
#print Dumper "command : SELECT $distinct_cl $fields FROM $table $join $where_cl $sort_closure $groupby $limit  " , [ split( $PARAM_DELIMITER, $params ) ];

    if ( defined( $gth ) ) {

        #print Dumper $gth ;
        $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], $params);
        my $res = $gth->execute( @{ [ split( $PARAM_DELIMITER, $params ) ] } ) ;

        while ( $res = $gth->fetchrow_hashref ) {
            if ( wantarray and ( "ARRAY" ne ref $data->{ 'select' } ) ) {
                defined $data->{ 'select' }
                  ? push @{ $return }, $res->{ $data->{ 'select' } }
                  : push @{ $return }, $res ;
            } else {
                push @{ $return }, $res ;
            } ## end else [ if ( wantarray and ( "ARRAY"...))]
        } ## end while ( $res = $gth->fetchrow_hashref)

        #print OUT "\n";
        #print OUT "param: $params \n";
        #print OUT "R E S : $res\n\n" ;
        #print OUT "-" x 30;

        #print OUT Dumper $return;
        #close OUT;
    } ## end if ( defined( $gth ) )
    return undef if scalar @{ $return } == 0 and !wantarray ;
    if ( wantarray ) {
        return @{ $return } ;
    } else {
        return $return ;
    } ## end else [ if ( wantarray ) ]

} ## end sub my_select

sub my_select_insert {
    my $self        = shift ;
    my $insert_data = shift ;

    #print Dumper $insert_data ;
    my $data_id = $self->my_select( {
           'where' => ( $insert_data->{ 'select' } ? $insert_data->{ 'select' } : $insert_data->{ 'data' } ),
           'from' => $insert_data->{ 'table' },
           'select' => ( defined $insert_data->{ 'selected_row' } ) ? ( $insert_data->{ 'selected_row' } ) : ( 'ALL' ),
           'relation' => 'AND'
         }
    ) ;

    unless ( $data_id ) {
        $data_id = $self->my_insert( {
                                       'insert' => $insert_data->{ 'data' },
                                       'table'  => $insert_data->{ 'table' },
                                     }
                                   ) ;
    } else {

        #print Dumper $data_id ;
        if ( defined $insert_data->{ 'selected_row' } ) {
            $data_id = $data_id->[ 0 ]->{ $insert_data->{ 'selected_row' } } ;
        } ## end if ( defined $insert_data...)
    } ## end else

    if ( !$data_id ) {
        $self->add_error( $insert_data->{ 'error' } ) ;
    } ## end if ( !$data_id )
    return $data_id ;
} ## end sub my_select_insert

sub handle_my_param {
    my $self  = shift ;
    my $param = shift || {} ;

    my $result = $self->my_select_insert(
        table  => $param->{ 'table' },
        select => $param->{ 'select' }
    );
}

sub my_delete {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    $self->{ 'DB_HANDLE' } = $DB if $DB and !defined $self->{ 'DB_HANDLE' } ;

    my $data   = shift ;
    my $return = undef ;

    #open( OUT, ">>c:\\xampp\\cgi-bin\\new_struct\\log\\my_select.txt" );
    my $table = $data->{ 'from' } ;

    my ( $params, $where_cl ) ;    # = $self->create_where_param($data) ;

    if ( defined $data->{ 'where_param' } ) {
        $params   = $data->{ 'where_param' } ;
        $where_cl = $data->{ 'where' } ;

    } else {
        ( $params, $where_cl ) = $self->create_where_param( $data ) ;
    } ## end else [ if ( defined $data->{ ...})]

    my $format = ( $data->{ 'format' } ? "$data->{format}" : "" ) ;

    #print "SELECT $fields FROM $table $where_cl, $params\n ";
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], "DELETE FROM $table $where_cl" ) ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], "$params" ) ;
    my $gth = $self->{ DB_HANDLE }->prepare( "DELETE FROM $table $where_cl" ) ;

    if ( $gth ) {
        my $res = $gth->execute( @{ [ split( $PARAM_DELIMITER, $params ) ] } ) ;
        return $res ;
    } else {
        return undef ;
    } ## end else [ if ( $gth ) ]

} ## end sub my_delete

sub create_question_mark_list {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;

    my $params   = shift ;
    my $kerdojel = "" ;
    my @params   = () ;

    foreach my $sql_type ( "where", "insert", "params" ) {
        if ( $params->{ $sql_type } ) {
            if ( "HASH" eq ref $params->{ $sql_type } ) {
                for my $item ( keys %{ $params->{ $sql_type } } ) {
                    if ( 'SCALAR' eq ref $params->{ $sql_type }->{ $item } ) {
                        $kerdojel .= ${ $params->{ $sql_type }->{ $item } } . ", " ;
                    } else {
                        $kerdojel .= " ?, " ;
                    } ## end else [ if ( 'SCALAR' eq ref $params...)]
                } ## end for my $item ( keys %{ ...})
            } else {
                $kerdojel = "" ;
                $kerdojel .= " ?," foreach split( ",", $params->{ $sql_type } ) ;
            } ## end else [ if ( "HASH" eq ref $params...)]
            $kerdojel =~ s/(.*),\s*$/$1/ ;
            last ;
        } ## end if ( $params->{ $sql_type...})
    } ## end foreach my $sql_type ( "where"...)

    return $kerdojel ;
} ## end sub create_question_mark_list

sub create_where_param {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    my $data        = shift ;
    my $where       = "WHERE " ;
    my $where_param = "" ;

    my $relation             = $data->{ 'relation' } ? ( 'and' )   : ( 'or' ) ;
    my $select_insert_fields = $data->{ 'where' }    ? ( 'where' ) : ( 'insert' ) ;

    return ( "", "" ) if scalar keys %{ $data->{ $select_insert_fields } } == 0 ;

    for ( grep { 'SCALAR' ne ref $data->{ $select_insert_fields }->{ $_ } } keys %{ $data->{ $select_insert_fields } } )
    {
        if ( 'ARRAY' eq ref $data->{ $select_insert_fields }->{ $_ } ) {
            for my $faktor_id ( @{ $data->{ $select_insert_fields }->{ $_ } } ) {
                $where .= $_ . " = " . ( "?" ) . " $relation " ;
                $where_param .= $faktor_id . $PARAM_DELIMITER ;
            } ## end for my $faktor_id ( @{ ...})

        } else {
            if ( $data->{ $select_insert_fields }->{ $_ } eq "IS NULL" ) {
                $where .= $_ . " " . "IS NULL" . " $relation " ;
            } else {
                $where .= $_ . " = " . ( "?" ) . " $relation " ;
                $where_param .= $data->{ $select_insert_fields }->{ $_ } . $PARAM_DELIMITER ;
            } ## end else [ if ( $data->{ $select_insert_fields...})]
        } ## end else [ if ( 'ARRAY' eq ref $data...)]
    } ## end for ( grep { 'SCALAR' ne...})
    $where =~ s/(.*?)$relation\s$/$1/ ;
    $where_param =~ s/(.*?)$PARAM_DELIMITER$/$1/ ;
    return ( $where_param, $where ) ;
} ## end sub create_where_param

sub create_param_list {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    my @ret_array ;
    my $data                 = shift ;
    my $where                = "" ;
    my $insert_or_call_param = "" ;

    if ( defined $data->{ "params" } ) {
        $insert_or_call_param = "params" ;

    } elsif ( defined $data->{ "insert" } ) {
        $insert_or_call_param = "insert" ;

    } ## end elsif ( defined $data->{ ...})

    if ( "HASH" eq ref $data->{ $insert_or_call_param } ) {
        return ( "" ) if scalar keys %{ $data->{ $insert_or_call_param } } == 0 ;
        for (
              grep { 'SCALAR' ne ref $data->{ $insert_or_call_param }->{ $_ } }
              keys %{ $data->{ $insert_or_call_param } }
            )
        {
            $where .= $data->{ $insert_or_call_param }->{ $_ } . $PARAM_DELIMITER ;
            push @ret_array, $data->{ $insert_or_call_param }->{ $_ } ;
        } ## end for ( grep { 'SCALAR' ne...})
    } else {
        $where .= $_ . $PARAM_DELIMITER
          and push @ret_array, $_
          foreach split( ",", $data->{ 'params' } ) ;
    } ## end else [ if ( "HASH" eq ref $data...)]
    $where =~ s/(.*?),\s*$/$1/ ;
    wantarray ? return @ret_array : return $where ;

} ## end sub create_param_list

sub create_insert_field_list {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;

    my $data            = shift ;
    my $selected_fields = "" ;

    if ( "HASH" eq ref $data->{ "insert" } ) {

        $selected_fields .= "$_, " for keys %{ $data->{ "insert" } } ;
        $selected_fields =~ s/(,\s)$// ;
    } else {
        $selected_fields = $data->{ "insert" } ;
    } ## end else [ if ( "HASH" eq ref $data...)]

    return $selected_fields ;
} ## end sub create_insert_field_list

sub create_select_field_list {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;

    my $data = $_[ 0 ] ;

    my $selected_fields = "" ;
    if ( defined $data->{ "select" } and $data->{ "select" } !~ /ALL/ ) {
        if ( "ARRAY" eq ref $data->{ "select" } ) {

            $selected_fields .= "$_, " for @{ $data->{ "select" } } ;
            $selected_fields =~ s/(,\s)$// ;
        } else {

            $selected_fields = $data->{ "select" } ;
        } ## end else [ if ( "ARRAY" eq ref $data...)]
    } else {
        $selected_fields = "*" ;
    } ## end else [ if ( defined $data->{ ...})]

    return $selected_fields ;
} ## end sub create_select_field_list

sub my_last_insert_id {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    $self->{ 'DB_HANDLE' } = $DB if $DB and !defined $self->{ 'DB_HANDLE' } ;

    my $table = shift ;
    $table =~ /((.*?)\.)*(.*)/ ;
    return $self->{ 'DB_HANDLE' }->last_insert_id( undef, $2, $3, undef ) ;

} ## end sub my_last_insert_id

sub get_table_fields {
    my $self = shift ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    my $exec ;
    my $res   = [] ;
    my $table = shift ;
    my $sth   = $self->{ 'DB_HANDLE' }->prepare( "SHOW COLUMNS FROM `$table`" ) ;
    my $ret ;

    if ( defined $sth ) {
        if ( $exec = $sth->execute() ) {
            while ( $ret = $sth->fetchrow_arrayref() ) {
                push @{ $res }, $ret->[ 0 ] ;
            } ## end while ( $ret = $sth->fetchrow_arrayref...)
        } ## end if ( $exec = $sth->execute...)
    } ## end if ( defined $sth )

    if ( !defined $sth || !defined $exec ) {
        return undef ;

    } else {
        wantarray ? ( return @{ $res } ) : ( return $res ) ;

    } ## end else [ if ( !defined $sth || ...)]
} ## end sub get_table_fields

sub disconnect {
    my $self = shift ;
    $self->{ 'DB_HANDLE' } = $DB if $DB and !defined $self->{ 'DB_HANDLE' } ;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;

    $self->{ 'DB_HANDLE' }->disconnect ;
} ## end sub disconnect

sub parameter_kezelo {
    'SCALAR' eq ref $_[ 1 ] ? ${ ( $_[ 1 ] ) } : $_[ 1 ] ;
} ## end sub parameter_kezelo

sub execute_sql {
    my $self   = shift;
    $self->start_time( @{ [ caller( 0 ) ] }[ 3 ], \@_ ) ;
    my $sql    = shift || return;
    my @params = @_;

    my $gth = $self->{ 'DB_HANDLE' }->prepare($sql) ;
    my $res;
    eval {
        $res = $gth->execute(@params) ;
    };

    if( $@ ) {
        $self->add_error( 'DB_ERROR', $@ );
    }
    return $res;
}

sub empty_tables {
    my $self = shift ;
    $self->{ 'DB_HANDLE' } = $DB if $DB and !defined $self->{ 'DB_HANDLE' } ;
    my $sth ;

    map {
        print "TRUNCATE $_\n" ;
        $sth = $self->{ 'DB_HANDLE' }->prepare( "TRUNCATE $_" ) ;
        $sth->execute() if $sth ;
    } @{ $_[ 0 ] } ;
} ## end sub empty_tables

END {
    $DB->disconnect() if $DB ;
} ## end END

1
