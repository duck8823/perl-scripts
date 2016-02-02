#!/usr/bin/env perl

use strict;
use warnings;

use Spreadsheet::XLSX;

use Getopt::Std;

our ($opt_s, $opt_l, $opt_d, $opt_h);
getopts("s:ld:h");
if($opt_h){
  print "Usage : perl cat_excel.pl [option] <FILE>\n";
  print "Options\n"
  print "-l:  シート名リストを表示する.\n;"
  print "-s:  シート名を指定する.\n";
  print "-d:  セパレータを指定する.(デフォルト: tab)\n"
  exit(-1);
}

$opt_d = "\t" unless($opt_d);

unless($ARGV[0]){
  print "Usage : perl cat_excel.pl [option] <FILE>\n";
  exit(-1);
}

my $excel = Spreadsheet::XLSX->new($ARGV[0]);

my @sheets = @{$excel->{Worksheet}};
my %sheet_map;
for(my $i = 0; $i < @sheets; $i++){
  $sheet_map{$sheets[$i]->{Name}} = $i;
}

if($opt_l){
  my @sheet_names = keys %sheet_map;
  while( my $key = shift @sheet_names){
    print "$key\n";
  }
  exit(1);
}

if($opt_s){
  my $index = $sheet_map{$opt_s};
  defined($index) or die"そのようなシートは存在しません. -l オプ ションで確認してください.";
  &cat_sheet($sheets[$index]);
} else {
  while( my $sheet = shift @sheets){
    printf("==> %s <==\n", $sheet->{Name});
    &cat_sheet($sheet);
    print "\n";
  }
}


sub cat_sheet {
  my ($sheet) = @_;
  $sheet->{MaxRow} ||= $sheet->{MinRow};
  foreach my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
    my $line;
    $sheet->{MaxCol} ||= $sheet->{MinCol};
    foreach my $col ($sheet->{MinCol} .. $sheet->{MaxCol}) {
      my $cell = $sheet->{Cells}[$row][$col];
      if($cell) {
        $line .= $cell->{Val} . $opt_d;
      }
    }
    $line =~ s/$opt_d$// and print $line if($line);
    print "\n";
  }
}

