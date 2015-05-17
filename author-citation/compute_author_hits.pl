#!/usr/bin/perl -w
# @author: Runwei Qiang 
# @create: 2015-5-2
use strict;
use PDL;
#$PDL::BIGPDL = 1;
use Algorithm::HITS;
use Data::Dumper;

my $usage = "perl $0 author_network year\n";
my $input = shift @ARGV or die $usage;
my $year = shift @ARGV or die $usage;

my $h = new Algorithm::HITS;
my @network = [];


open FH, $input or die $!;
my %author2id;
my @authors;
my $idx = 0;
my ($a, $b);
while (<FH>) {
    if (m/(.+) ==> (.+)/g) {
        my $a = $1;
        my $b = $2;

        unless (defined $author2id{$a}) {
            $author2id{$a} = $idx;
            push @authors, $a;
            $idx += 1;
        }
        unless (defined $author2id{$b}) {
            $author2id{$b} = $idx;
            push @authors, $b;
            $idx += 1;
        }    

        push $network[0], $author2id{$a};
        push $network[0], $author2id{$b};
    } else {
        print "[warning] no author detected in line $_\n";
    }
}
close FH;

$h->graph(@network);
$h->iterate(1);
my $r = $h->result();

foreach (keys $r) {
    open OUT, ">author$year.$_.hits";
    my $string = "" . $r->{$_};
    chomp($string);
    $string =~ s/\[//g;
    $string =~ s/\]//g;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    my @elements = split m/\s+/s, $string;
    foreach (0..$#authors) {
        print OUT $authors[$_], "\t", $elements[$_], "\n";
    }
    close OUT;
}

