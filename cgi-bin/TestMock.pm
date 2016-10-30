package TestMock;

use strict;
use warnings;

use Carp qw( confess );

use feature qw( state );

use FindBin;
use File::Copy qw( copy );

use Readonly;
use JSON::XS qw( decode_json );

use parent qw( Test::MockModule );

use Exporter qw( import );
our @EXPORT_OK = qw( remove_test_db set_test_dependent_dp );

Readonly my $NO_WARNINGS              => 'No warning' ;
Readonly my $ALL_INPUTS               => 'all_inputs' ;
Readonly my $MAX_NUM_OF_FILE_OP_TRIAL => 10           ;

my $BUFFERS = {
    warn => {
        IN   => undef,
        OUT  => undef,
        GOTO => undef,
    },
    err => {
        IN   => undef,
        OUT  => undef,
        GOTO => undef,
    },
    rpipe => {
        IN   => undef,
        OUT  => undef,
    }
};

BEGIN {
    $SIG{__WARN__} = sub {
        my $caller_sub = (caller( 1 ))[ 3 ] || do {
            print @_ and die;
        };
        $BUFFERS->{warn}{IN}{$caller_sub} ||= [];
        push @{ $BUFFERS->{ warn }{ IN }{ $caller_sub } }, join q{}, @_;
    };

    *CORE::GLOBAL::die = sub {
        my $caller_sub = (caller( 1 ))[ 3 ] || do {
            print @_ and die;
        };
        $BUFFERS->{err}{$caller_sub} ||= [];
        push @{ $BUFFERS->{err}{IN}{$caller_sub}}, join q{}, @_ ;

        if ( defined $BUFFERS->{ err }{ GOTO }{ $caller_sub }) {
            goto $BUFFERS->{ err }{ GOTO }{ $caller_sub };
        }
    };

    *CORE::GLOBAL::readpipe = sub {
        my $caller_sub = (caller( 1 ))[ 3 ] || do {
            print @_ and die;
        };
        $BUFFERS->{ rpipe }{ $caller_sub } ||= [];
        push @{ $BUFFERS->{ rpipe }{ IN }{ $caller_sub } }, join q{}, @_ ;

        return shift @{ $BUFFERS->{ rpipe }{ OUT }{ $caller_sub } };
    };
}

sub new {
    my $class = shift;
    my $self  = {};

    if ( ref $_[ 0 ] eq 'ARRAY' ) {
        &init_array( $self, @_ );

    } else {
        $self = $class->SUPER::new( @_ );
        $self->{ IO } = {};
    }

    return $self;

}

sub init_array {
    my $self    = shift;
    my $to_mock = shift;

    foreach my $mock ( @{ $to_mock } ) {
        $self->{ $mock->{ module } } = __PACKAGE__->SUPER::new( $mock->{ module} ) ;
        $self->{ $mock->{ module } }{IO} = {};
        $self->{ $mock->{ module } }->mock( $_ ) foreach @{ $mock->{ subs } };
    }
}

sub mock {
    my $self     = shift;
    my $package  = $self->{ _package };
    my $function = q{};

    $self->{ IO }{ $_{ 0 } } = {
        IN       => [],
        OUT      => [],
        OLD_SUB  => undef,
    };

    $self->{ IO }{ $_[ 0 ] }{ OLD_SUB } = eval '\&' . $package . '::' . $_[ 0 ];

    {
        no warnings 'redefine';

        if ( ref $_[ 1 ] eq 'CODE' ) {
            $self->SUPER::mock( @_ );

        } elsif ( $_[ 0 ] eq 'new' ) {
            $function =
            '*' . $package . '::' . $_[ 0 ] . ' = sub {
                &mocked_new( \'' . $package . '\', \'' . $_[ 0 ] . '\');
            }';
            eval $function;

        } else {
            $function =
            '*' . $package . '::' . $_[ 0 ] . ' = sub {
                $self->check_in_out_params( @_, \'' . $_[ 0 ] . '\';
            }';
            eval $function;

        }
    };


};

sub set_test_dependent_db {
    my $sqlite_to_mock = shift || do {
        die 'Test DB env. variable is not set' unless $ENV{ TEST_SQLITE };
        my $sq = &convert_filename_to_sqlite_path( (caller( 0 ) )[ 1 ] );

        copy_test_db( $ENV{ TEST_SQLITE }, $sq );
    };
    $ENV{ TEST_SQLITE } = $sqlite_to_mock;

}

sub copy_test_db {
    my $src = shift || confess 'no src' ;
    my $trg = shift || confess 'no dst' ;

    for my $trial ( 1 .. $MAX_NUM_OF_FILE_OP_TRIAL ) {
        return if copy( $src, $trg );
        print "copy($src, $trg) FAILED \n";
        sleep( 1 );
    }
    confess 'copy_test_db ERROR';
}

sub remove_test_db {
    my $test_db = &convert_filename_to_sqlite_path( (caller( 0 ) )[ 1 ] );

    -e $test_db or confess "$test_db doesn't exist";

    for my $trial ( 1 .. $MAX_NUM_OF_FILE_OP_TRIAL ) {
        return if unlink( $test_db );
        print "unlink( $test_db ) failure\n";
        sleep( 1 ) ;
    }
}

sub convert_filename_to_sqlite_path {
    my $file = shift;
    $file =~s{.*/}{};
    return "$file.sqlite";
}

sub add_output_to_rpipe {
    my $self = shift;
    return $self->add_output( 'rpipe', @_ );
}

sub get_warning {
    my $self = shift;
    return $self->get_sig( 'warn', @_ );
}

sub get_die {
    my $self = shift;
    return $self->get_sig( 'err', @_ );
}

sub count_warning {
    my $self = shift;
    return $self->count_sigs( 'warn', @_ );
}

sub count_dies {
    my $self = shift;
    return $self->count_sigs( 'err', @_ );
}

sub add_output {
    my $self     = shift;
    my $buf_type = shift;
    my $function = shift;
    my $package  = ref $self ? $self->{ _package } : '';

    my $buf = &get_buff_by_type( $buf_type );

    push @{ $buf->{ OUT }{ $package ? $package . "::" . $function : $function } }, @_;
}

sub get_sig {
    my $self     = shift;
    my $buf_type = shift;
    my $function = shift;
    my $package  = ref $self ? $self->{ _package } : '';

    my $buf = &get_buff_by_type( $buf_type );

    if ( $self->count_sigs( $buf_type, $function ) == 0 ) {
        return $NO_WARNINGS;
    } else {
        return shift @{ $buf->{ IN }{ $package ? $package . "::" . $function : $function } };
    }
}

sub count_sigs {
    my $self     = shift;
    my $buf_type = shift;
    my $function = shift;
    my $package  = ref $self ? $self->{ _package } : '';

    my $buf = &get_buff_by_type( $buf_type );

    return scalar @{ $buf->{ IN }{ $package ? $package . "::" . $function : $function } // [] };
}

sub get_buff_by_type {
    my $type = shift;

    return $BUFFERS->{ $type } || {};
}

sub unmock {
    no warnings 'redefine';

    my $self     = shift;
    my $function = shift;
    my $package  = ref $self ? $self->{ _package } : '';

    my $eval = '*' . $package . '::' . $function . '*' . '$self->{ IO }{ $function }{ $OLD_SUB }';

    eval $eval;
}

sub check_in_out_params {
    my $self = shift;
    my $called_func_name = pop;

    my $IN  = $self->{ IO }{ $called_func_name }{ IN };
    my $OUT = shift @{ $self->{ IO }{ $called_func_name }{ OUT } };

    push @{ $IN }, @_;

    unless ( defined $OUT ) {
        if ( defined ( my $goto = $self->{ GOTO }{ $called_func_name } ) ) {
            goto $goto;
        }
        return;
    }

    if ( defined ( my $goto = $self->{ GOTO }{ $called_func_name } ) ) {
        goto $goto;
    }

    return wantarray && 'ARRAY' eq ref $OUT ? @{ $OUT } : $OUT;
}

sub mocked_new {
    my $self = {};
    bless $self, $_[ 0 ];
    return $self;
}

sub add_return_value {
    my $self     = shift;
    my $function = shift;

    if ( !defined $function ||
         !defined $self->{ IO }{ $function } ) {
        confess 'function is mising from paramter or $obj->mock call is missing\n';
    }

    push @{ $self->{ IO }{ $function }{ OUT } }, @_;
}

sub add_goto {
    my $self     = shift;
    my $function = shift;
    my $label    = shift;

    if ( ref $self eq __PACKAGE__ ) {
        $self->{ GOTO }{ $function } = $label;

    } else {
        $BUFFERS->{ err }{ GOTO }{ $function } = $label;

    }
}

sub delete_goto {
    my $self     = shift;
    my $function = shift;

    if ( ref $self eq __PACKAGE__ ) {
        delete $self->{ GOTO }{ $function };

    } else {
        delete $BUFFERS->{ err }{ GOTO }{ $function };

    }
}

sub get_input_value {
    my $self     = shift;
    my $function = shift;

    $self->_get_input_value( $function );

}


sub get_input_values {
    my $self     = shift;
    my $function = shift;
    return $self->_get_input_value( $function, $ALL_INPUTS );

}

sub _get_input_value {
    my $self     = shift;
    my $function = shift;

    my $all_inputs = shift // q{};

    if( !defined $function ||
        !defined $self->{ IO }{ $function } ) {
        confess "function is missing from parameter or \$obj->mock cakk is missing\n";
    }

    if ( $self->count_input_buffer( $function ) == 0 ) {
        confess 'input buffer is empty for: ' . $function;
    }

    return $all_inputs eq $ALL_INPUTS ? $self->{ IO }{ $function }{ IN } : shift @{ $self->{ IO }{$function}{ IN } };

}

sub input_values_contain {
    my $self = shift;
    my $inputs = $self->get_input_values( shift );
    my $match = shift;

    return [ grep {/$match/} @{ $inputs } ]->[ 0 ];
}

sub empty_in_buffer {
    my $self     = shift;
    my $function = shift;

    $self->empty_buffer( $function, 'IN' );
}

sub empty_out_buffer {
    my $self     = shift;
    my $function = shift;

    $self->empty_buffer( $function, 'OUT' );
}

sub count_output_buffer {
    my $self     = shift;
    my $function = shift;

    return $self->count_buffer( $function, 'OUT' );
}

sub count_input_buffer {
    my $self     = shift;
    my $function = shift;

    return $self->count_buffer( $function, 'IN' );
}

sub get_input_buffer {
    my $self     = shift;
    my $function = shift;

    return $self->get_buffer( $function, 'IN' );
}

sub get_output_buffer {
    my $self     = shift;
    my $function = shift;

    return $self->get_buffer( $function, 'OUT' );
}

sub empty_buffer {
    my $self     = shift;
    my $function = shift;
    my $buffer   = shift;

    $self->{IO}{ $function }{ $buffer } = [];
}

sub count_buffer {
    my $self     = shift;
    my $function = shift;
    my $buffer   = shift;

    return scalar @{ $self->{ IO }{ $function }{ $buffer } };
}

sub get_result_of_fcgi {
    my $cgi_path = shift;
    my $param    = shift;

    open( my $cgi, "-|", $cgi_path, $param ) or die "Can't open pipe to:" . $cgi_path;
    my @res = <$cgi>;
    close $cgi;

    my $res_s = pop @res;

    return {
        ref  => $res_s ? decode_json( $res_s ) : [],
        json => $res_s
    };

};


1;
