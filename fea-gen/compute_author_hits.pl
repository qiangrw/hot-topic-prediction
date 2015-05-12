#!/usr/bin/perl -w
# @author: Runwei Qiang 
# @create: 2015-5-2
use strict;
use PDL;
$PDL::BIGPDL = 1;
use Algorithm::HITS;
use Data::Dumper;

my $usage = "perl $0 author_network author_id\n";
my $input = shift @ARGV or die $usage;
my $author_file = shift @ARGV or die $usage;

my $h = new Algorithm::HITS;
my @network = [];


open FH, $input or die $!;
my %article2id;
my @articles;
my $idx = 0;
my ($a, $b);
while (<FH>) {
    if (m/(\d+) ==> (\d+)/g) {
        print $1, "\t", $2, "\n";
        push $network[0], $1;
        push $network[0], $2;
    } else {
        print "[warning] no author detected in line $_\n";
    }
}
close FH;

$h->graph(@network);
$h->iterate(1);
my $r = $h->result();

my %author_hash;
open AF, $author_file or die $!;
while (<AF>)  {
   my ($id, $name) = split /\t/;
   $author_hash{$id} = $name;
}
close AF;

foreach (keys $r) {
    open OUT, ">author.$_.hits";
    my $string = "" . $r->{$_};
    chomp($string);
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    my @elements = split /\s+/, substr($string, 0, -1);
    foreach (0..$#articles) {
        print OUT $_, "\t", $elements[$_+2], "\n";
    }
    close OUT;
}

