#!/usr/bin/perl -w
# @author: Runwei Qiang 
# @create: 2015-5-2
use strict;
use PDL;
#$PDL::BIGPDL = 1;
use Algorithm::HITS;
use Data::Dumper;

my $usage = "perl $0 author_network paperlist year\n";
my $input = shift @ARGV or die $usage;
my $paperlist = shift @ARGV or die $usage;
my $year = shift @ARGV or die $usage;

my $h = new Algorithm::HITS;
my @network = [];


open FH, $input or die $!;
my %author2id;
my @authors;
my $idx = 0;
my ($a, $b);
while (<FH>) {
    chomp;
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
$h->iterate(100);
my $r = $h->result();

open FH, $paperlist or die $!;
my %paper2author;
while (<FH>) {
    my @elements = split /\t/;
    print "ERROR in line $_\n" unless $#elements >= 1;
    print "ERROR in line $_\n" if $elements[1] eq "";
    $paper2author{$elements[0]} = $elements[1];
}
close FH;

foreach (keys $r) {
    my $string = "" . $r->{$_};
    chomp($string);
    $string =~ s/\[//g;
    $string =~ s/\]//g;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    my @elements = split m/\s+/s, $string;
    my %author_score;

    foreach (0..$#authors) {
        #print OUT $authors[$_], "\t", $elements[$_], "\n";
        my $author_name = $authors[$_];
        my $score = $elements[$_];
        $author_score{$author_name} = $score;
    }

    open OUT, ">", "../fea-gen/score/year$year.author.$_.hits";
    foreach (keys %paper2author) {
        my $author_name = $paper2author{$_};
        $author_score{$author_name} = 0 unless defined $author_score{$author_name};
        print OUT $_, "\t", $author_score{$author_name}, "\n";
    }
    close OUT;
}

