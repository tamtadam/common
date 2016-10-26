package WinLin;

use strict;
use File::Copy::Recursive qw(dircopy);
use vars qw(*mycopy);

*mycopy = *File::Copy::Recursive::copy;

sub my_rel2abs {
    my $file = shift;
    my $abs = File::Spec->rel2abs( $file );
    return $file =~ m{/} ? back2slash( $abs ) : $abs;
}

sub back2slash {
    (my $temp = shift) =~ s{\\}{/}g;
    return $temp;
}

sub winpath2linpath {
    return join '/', split(qr(\\), $_[0]);
}

sub get_filename {
    $_[ 0 ] =~m~(.*)((/|\\)+)(.*?)$~;
    return $4;
}

sub get_target_path {
    $_[ 0 ] =~/(.*?)$_[1]/;
    return $1;
}

sub get_project_from_path {
    $_[ 0 ] =~/$_[1](.*?)\/.*$/i;
    return $1;
}

sub mycopy_func { 
    &mycopy(@_);
    mycopy_showprogress(@_); }

sub mycopy_showprogress {
    my ($remaining) = @_;
    next unless $_[ 0 ];
    next unless $_[ 1 ];
    print " " x (length ("copying $_[0] to $_[1].     ") + 40);
    print "\r";
    printf "copying $_[0] to %s\r",$_[1];
}

1;