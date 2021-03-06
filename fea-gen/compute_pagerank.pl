#!/usr/bin/perl -w
# @author: Runwei Qiang 
# @create: 2015-5-2
use strict;
use Algorithm::PageRank;
use Data::Dumper;

my $usage = "perl $0 acl.txt to_year\n";
my $input = shift @ARGV or die $usage;
my $year = shift @ARGV or die $usage;

my $start_year = $year == 2011 ? 1 : 2;     # 2001 / 2002
my $end_year = $year == 2011 ? 10 : 11 ;    # 2011 / 2012

my $pr = new Algorithm::PageRank;
my @network = [];

open FH, $input or die $!;
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
            next unless int($ayear) >= $start_year && int($ayear) <= $end_year;
        }
        if ($b =~ /[A-Z](\d+)-/) {
            $byear = $1 + 0;
            next unless int($byear) >= $start_year && int($byear) <= $end_year;
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
$pr->iterate(10);
my $r = $pr->result();

open OUT, ">score/year$year.pagerank";
my $string = "" . $r;
chomp($string);
$string =~ s/^\s+//;
$string =~ s/\s+$//;
my ($start, $content, $end) = split /\n/, $string;
$content = substr($content, 2, -1);
print $content;
my @elements = split /\s+/, $content;
foreach (0..$#articles) {
    print OUT $articles[$_], "\t", $elements[$_], "\n";
}
close OUT;   
