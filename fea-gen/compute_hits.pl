#!/usr/bin/perl -w
# @author: Runwei Qiang 
# @create: 2015-5-2
use strict;
use Algorithm::HITS;
use Data::Dumper;

my $usage = "perl $0 acl.txt to_year\n";
my $input = shift @ARGV or die $usage;
my $year = shift @ARGV or die $usage;
die "year should be 2011/2012\n" if $year != 2011 && $year != 2012;

my $h = new Algorithm::HITS;
my @network = [];

my $start_year = $year == 2011 ? 1 : 2;     # 2001 / 2002
my $end_year = $year == 2011 ? 10 : 11 ;    # 2011 / 2012

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

$h->graph(@network);
$h->iterate(100);
my $r = $h->result();

foreach (keys $r) {
    open OUT, ">score/year$year.$_.hits";
    my $string = "" . $r->{$_};
    chomp($string);
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    my @elements = split /\s+/, substr($string, 0, -1);
    foreach (0..$#articles) {
        print OUT $articles[$_], "\t", $elements[$_+2], "\n";
    }
    close OUT;
}

