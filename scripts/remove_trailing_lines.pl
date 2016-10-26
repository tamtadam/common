use strict;
use File::Slurp;

open(my $fh, "<:encoding(UTF-8)", $ARGV[0]) or die ;

my @cont = <$fh>;
close $fh;
my $cnt = 0;
my @res = 0;

map {
    if( /(.*?)( +?)$/ ) {
        s/(.*?)( +?)$/$1/;
        $cnt += scalar @res;
    }
} @cont [ 1 .. $#cont ];

open($fh, ">:encoding(UTF-8)", $ARGV[0]);
print $fh @cont;
close $fh;

print $cnt . " line(s) are/is modified\n";
