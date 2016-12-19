#!/usr/bin/perl
use strict ;

#my $target_dir = '/mnt/J\:/dev_users/PROJECT\ Documentation/OmniBB/SYSTEM_TEST/DB_DIR/' ;
#my $target_dir = '/home/deveushu/Desktop/dmp/' ;
my $target_dir = '/home/trenyik/backups/';
my $db         = 'client1194dbdiab';
system( &no_data() ) ;
system( &data() ) ;

sub data{
    print 'mysqldump --extended-insert=FALSE --complete-insert=TRUE ' . $db . ' >' . &create_dump_file_name( "data" ) . "\n";
    return 'mysqldump --extended-insert=FALSE --complete-insert=TRUE ' . $db . ' >' . &create_dump_file_name( "data" ) ;
}

sub no_data{
    print 'mysqldump --extended-insert=FALSE --complete-insert=TRUE --no-data ' . $db . ' >' . &create_dump_file_name( "no_data" ) . "\n";
    return 'mysqldump --extended-insert=FALSE --complete-insert=TRUE --no-data ' . $db . ' >' . &create_dump_file_name( "no_data" ) ;
}

sub create_dump_file_name{
    return $target_dir . &get_localtime_as_str() . "_" . shift() . ".sql" ;
}


sub get_localtime_as_str{
    my @months = qw(jan feb mar apr may jun jul aug sep oct nov dec);
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

    $year += 1900 ;
    return $year . "_" . $months[ $mon ] . "_" . $mday ;
}