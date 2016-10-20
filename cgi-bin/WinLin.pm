package WinLin;

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
    $_[ 0 ] =~m~(.*)((/)+)(.*?)$~;
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

1;