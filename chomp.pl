#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV == 0){
	print "Usage : perl chomp.pl <INPUT.file>\n";
	exit(-1)
} 

foreach my $file(@ARGV){
   my $print;
   open (FILE, $file) or die "$!";
   foreach my $line(<FILE>){
        $line =~ s/\x0D\x0A|\x0D|\x0A/\n/;
        $print = $print.$line;
   }
   close(FILE);
   open(FILE,">$file");
   print FILE $print;
   close(FILE);
}
