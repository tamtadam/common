#!/usr/bin/perl -w

use strict;
use IPC::Open3;
use POSIX;
use Data::Dumper;
use File::Copy;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

my $zip = Archive::Zip->new();


my $base_dir = '/tmp/';
mkdir( $base_dir . '/images' );
mkdir( $base_dir . '/zipper' );
mkdir( $base_dir . '/zipped' );

#my $pid = open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR, 'raspistill -w 640 -h 480 -t 0 -k -o ' . $base_dir . '/images/my_pics%02d.jpg' ) or die "open3() failed $!";
my $zip_cnt = 0;

while ( 1 ){
 
    #move( $base_dir . '/images' . '/*.jpg', $base_dir . '/zipper/' );
    for my $file (glob $base_dir . '/images/' . '/*.*') {
        next if $file =~/last/;
        move ($file, $base_dir . '/zipper/') or die $!;
        if ( $file !~/avi/ && $file =~/-00/ ) {
            $file =~s/images/zipper/;
            system( 'mpack -s "home camera" ' . $file . ' trenyik.adam@gmail.com &' );
            print 'mpack -s "home camera" ' . $file . ' trenyik.adam@gmail.com &' . "\n" ;
        }
        print $file . " moved to zipper folder\n";
    }


    my $size = get_directory_size( $base_dir . '/zipper' ) ;
    my $file_cnt = count_files_in_a_dir( $base_dir . '/zipper' );
    my $last_file;

    if( $file_cnt > 5 ) {
 #       kill "KILL", $pid;

        system( "tar -cvf " . $base_dir . 'zipped/' . $zip_cnt . ".tar " . $base_dir . 'zipper/' . "*.*");
        print "tar -cvf " . $base_dir . 'zipped/' . $zip_cnt . ".tar " . $base_dir . 'zipper/' . "*.*" . "\n";

        unlink( $base_dir . 'zipper/*.*' );

        system( 'rsync -avz --remove-source-files -e "ssh -i /home/trenyik/.ssh/key " ' . $base_dir . 'zipped/ trenyik@178.62.53.9:~/pimage2/ &' );
        print 'rsync -avz --remove-source-files -e "ssh -i /home/trenyik/.ssh/key " ' . $base_dir . 'zipped/ trenyik@178.62.53.9:~/pimage2/ &';

        for my $file (glob $base_dir . '/zipper/' . '/*.*') {
            unlink ($file) or die $!;
        }
=pod
        $zip->addTree( $base_dir . '/zipper' );

        # # Write the files to zip.
        if ($zip->writeToFileNamed( $base_dir . '/zipper/' . $zip_cnt++ . '.zip' ) == AZ_OK)
        {
            # write to disk
            print "\n\nArchive created successfully!\n";
        } else {
            print "Error while Zipping !";
        }
=cut
#        $pid = open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR, 'raspistill -w 640 -h 480 -t 0 -k -o /tmp/images/my_pics%02d.jpg' ) or die "open3() failed $!";
        $file_cnt = 0;
        $zip_cnt++;
        print $zip_cnt . " zip cnt\n";
        if ( $zip_cnt > 40 ) {
            $zip_cnt = 0;
        }
    }

    print "\n" . $size . " size\n";
    print "\n" . $file_cnt . " counter\n";

#    print CHLD_IN "\n";
    sleep( 1 );
}

#kill "KILL", $pid;

sub get_directory_size {
    my $dir = shift || ".";
    my @size = `du -sch $dir`;
    $size[ 0 ] =~/(\d*.?\d+)/;
    my $gb = $1 // 0;
    $gb =~s/,/./;
    if( $size[ 0 ] =~/G/ ) {
        $gb *= 1024;
    }
    return $gb * 1;
}

sub count_files_in_a_dir {
    my $dir = shift || '.' ;
    my $dh;
    opendir $dh, $dir;
    my $num_entries = () = readdir($dh);
    closedir $dh;
    return $num_entries;
}

