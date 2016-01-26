#!/usr/bin/env perl

use strict;
use warnings;

open(OMNI,"<$ENV{HOME}/.vim-cpan-module-cache") or die"$!";
local $/ = undef;
my $data = <OMNI>;
close(OMNI);


my @lib = split(":",$ENV{PERL5LIB});

my @filelist;
for(@lib){
  next unless($_);
  my $list = &get_files($_,$_);
  push(@filelist,@$list);
}

open(OMNI,">>$ENV{HOME}/.vim-cpan-module-cache") or die"$!";
foreach (@filelist){
  if(index($data,$_) == -1){
    print OMNI "$_\n";
  }
}
close(OMNI);

sub get_files {
  my $dir = shift;
  my $root = shift;
  my $filelist = shift;
  opendir (DIR, "$dir");
  my @list = grep /^[^\.]/, readdir DIR;
  closedir DIR;
  foreach my $file (@list) {
    if (-d "$dir/$file"){
      $filelist = &get_files("$dir/$file", $root, $filelist);
    } else {
      if($file =~ /\.pm$/){
        my $mod = "$dir/$file";
        $mod =~ s/$root\///;
        $mod =~ s/\.pm$//;
        $mod =~ s/\//::/g;
        push (@$filelist, $mod);
      }
    }
  }
  return $filelist;
}
