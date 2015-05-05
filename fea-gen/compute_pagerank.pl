#!/usr/bin/perl -w
# @author: Runwei Qiang 
# @create: 2015-5-2
use strict;
use Algorithm::PageRank;
use Data::Dumper;

my $usage = "perl $0 acl.txt to_year\n";
my $input = shift @ARGV or die $usage;
my $year = shift @ARGV or die $usage;

my $pr = new Algorithm::PageRank;
my @network = [];

open FH, $input or die $usage;
my %article2id;
my @articles;
my $idx = 0;
my ($a, $b, $ayear, $byear);
while (<FH>) {
    if (m/([A-Z0-9-]+) ==> ([A-Z0-9-]+)/g) {
        $a = $1;
        $b = $2;

        if ($a =~ /[A-Z](\d+)-/) {
            $ayear = $1 + 0;
            next unless int($ayear) >= 0 && int($ayear) <= 10;
        }
        if ($b =~ /[A-Z](\d+)-/) {
            $byear = $1 + 0;
            next unless int($byear) >= 0 && int($byear) <= 10;
        }
        
        unless (defined $article2id{$a}) {
            $article2id{$a} = $idx;
            push @articles, $a;
            $idx += 1;
        }
        unless (defined $article2id{$b}) {
            $article2id{$b} = $idx;
            push @articles, $b;
            $idx += 1;
        } 
        push $network[0], $article2id{$a};
        push $network[0], $article2id{$b};
    }
}
close FH;

$pr->graph(@network);
$pr->iterate(100);
my $r = $pr->result();

print $r, "\n";
$idx = 0;
foreach (@articles) {
    print "$idx\t$_\n";
    $idx += 1;
}
