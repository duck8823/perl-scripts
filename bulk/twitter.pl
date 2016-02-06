#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;
use Net::Twitter;

use Date::Parse;

use Encode;

use Unicode::Japanese;

use HTML::Entities;
use Term::ANSIColor;

unless($ARGV[0]){
  print "Usage: twitter.pl [option] <command>\n";
  exit(-1);
}

our ($opt_r, $opt_h);
getopts('q:r:h');
unless($opt_r){
  $opt_r = 300;
} elsif($opt_r =~/\D/){
  print "rは正の整数でなければなりません。\n";
  exit(-1);
}
if($opt_h){
  print "Usage: twitter.pl [option] <command>\n\n"
    ."Commands:\n"
    ." -- timeline\n"
    ."\ttimeline\n"
    ."\tsearch\n"
    ." -- update"
    ."\tupdate"
    ."\n";
  exit(0);
}

my $consumer_key = 'XXX',
my $consumer_secret = 'XXX',
my $token = 'XXX';
my $token_secret = 'XXX';

my $nt = Net::Twitter->new(
  traits => ['API::RESTv1_1'],
  consumer_key => $consumer_key,
  consumer_secret => $consumer_secret,
  access_token => $token,
  access_token_secret => $token_secret,
  ssl => 1
);

if($ARGV[0] eq 'timeline'){
  my $id;
  while(1==1){
    my $statuses;
    if($id){
      $statuses = $nt->home_timeline({since_id=>$id, count=>20});
    }else{
      $statuses = $nt->home_timeline({count=>20});
    }
    my $timeline = &timeline($statuses);
    $id = ${$timeline->{id}} if(${$timeline->{id}});
    &print_timeline($timeline->{entries});
    sleep($opt_r);
  }
}elsif($ARGV[0] eq 'search'){
  my $id;
  unless($ARGV[1]){
    print "Usage: twitter.pl search <keyword>\n";
    exit(-1);
  }
  my $keyword = decode("utf-8",$ARGV[1]);
  my @keywords = split(/\s+?/,$keyword);
  while(1==1){
    my $statuses;
    if($id){
      my $r = $nt->search({q=>$keyword, result_type=>"recent", lang=>"ja", locale=>"ja_JP", since_id=>$id, count=>20});
      $statuses = \@{$r->{statuses}};
    }else{
      my $r = $nt->search({q=>$keyword, result_type=>"recent", lang=>"ja", locale=>"ja_JP", count=>20});
        $statuses = \@{$r->{statuses}};
    }
    my $timeline = &timeline($statuses, \@keywords);
    $id = ${$timeline->{id}} if(${$timeline->{id}});
    &print_timeline($timeline->{entries});
    sleep($opt_r);
  }
} elsif($ARGV[0] eq 'update'){
  print "tweet:\n";
  my $text = <STDIN>;
  chomp $text;
  while(1==1){
    unless($text){
      print "何か入力してください。\n";
      $text = <STDIN>;
      chomp $text;
    }else{
      last;
    }
  }
  print "\n".$text."\n";
  print "上記の内容でつぶやきますか? [y/N]\n";
  while(1==1){
    my $check = <STDIN>;
    chomp $check;
    if($check eq 'y' || $check eq 'Y'){
      $nt->update(decode("utf-8",$text));
      last;
    } elsif($check eq 'n' || $check eq 'N'){
      print "つぶやきをキャンセルしました。\n";
      last;
    } else {
      print "y(Y)またはn(N)を入力してください。\n";
      next;
    }
  }
} else {
  print "unrecognized command '" . $ARGV[0] ."'\n";
  exit(-1);
}


sub timeline {
  my $statuses = shift @_;
  my $keywords = shift @_;
  my $tmp_id;
  my @entries;
  my %hash;
  for my $status (@$statuses){
    $tmp_id = $status->{id} unless($tmp_id);
    my $time = localtime(str2time($status->{created_at}));
    my $user = &highlight($keywords, "$status->{user}{name}\(\@$status->{user}{screen_name}\)");
    my $text = &highlight($keywords, $status->{text});
    push(@entries,encode("utf-8", decode_entities("$time\n$user\n$text")));
  }
  $hash{entries} = \@entries;
  $hash{id} = \$tmp_id;
  return \%hash;
}

sub print_timeline {
  my $entries = shift @_;
  for(reverse(@$entries)){
    print "$_\n";
    for(1..10){
      print "=";
    }
    print "\n";
  }
}

sub highlight {
  my $keyword = shift @_;
  my $text = shift @_;
  for(@$keyword){
    my @matches = $text =~ /$_/ig;
    my %slice;
    @slice{@matches} = ();
    @matches = keys %slice;
    for(@matches){
      my $highlight = color('red').$_.color('reset');
      $text =~ s/$_/$highlight/g;
    }
  }
  return $text;
}
