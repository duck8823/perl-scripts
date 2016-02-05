#!/usr/bin/env perl

use strict;
use warnings;

use File::Find;
use File::Path;
use File::Copy;

use Cwd;

unless($ARGV[1]){
  print "Usage : perl regex_copy.pl <FROM> <TO>\n";
  exit(-1);
}

my $dst_base = $ARGV[1] =~ /^\//m ? $ARGV[1] : getcwd() . "/" . $ARGV[1];
my ($base_dir) = split(/[\.\(\{]/, $ARGV[0]);
length($base_dir) > 1 and $base_dir =~ s/\/$//;
find(\&regex_copy, $base_dir);

sub regex_copy {
  my $src = "$File::Find::dir/$_";
  if($src =~ /$ARGV[0]/m){
    (my $dst = $src ) =~ s/$base_dir/$dst_base/;
    my @path = split(/\//, $dst);
    my @dst_dirs = ();
    ($dst_dirs[0] = $dst) =~ s/$path[$#path]//;
    mkpath(@dst_dirs);
    copy($src, $dst) or die"$!";
  }
}
