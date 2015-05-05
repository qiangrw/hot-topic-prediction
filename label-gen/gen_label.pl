#!/usr/bin/perl -w
# @author Runwei Qiang
# @create 2015-05-05
# @description: generate the topic strength label for training and test dataset 
use strict;

my $usage = "perl $0 acl.txt matrix_file year(2011/2012)\n";
my $input = shift @ARGV or die $usage;
my $matrix = shift @ARGV or die $usage;
my $year = shift @ARGV or die $usage;  # year should be 2012 or 2013
die $usage if $year != 2012 && $year != 2011;

my %document_topic;
my @topic_weight;
my $topic_no = 0;
open MR, $matrix or die $!;
while (<MR>) {
    chomp;
    my ($pid, @topics) = split /\t/;
    $document_topic{$pid} = \@topics;
    $topic_no = scalar @topics;
}
close MR;
print "$topic_no topics detected\n";
foreach(0..$topic_no-1) {
    $topic_weight[$_] = 0;
}
print "topic weight scalar = ", scalar @topic_weight, "\n";


my $to_year = $year == 2011 ? 11 : 12;
my $start_year = $year == 2011 ? 1 : 2;     # 2001 / 2002
open FH, $input or die $!;
my ($a, $b, $ayear, $byear);
open OUT, ">label$year.raw";
my $missing_cnt = 0;
my $total_cnt = 0;
while (<FH>) {
    if (m/([A-Z0-9-]+) ==> ([A-Z0-9-]+)/g) {
        $a = $1;
        $b = $2;
        if ($a =~ /[A-Z](\d+)-/) {
            $ayear = $1 + 0;
            next unless int($ayear) == $to_year;  # should be 2012/2013
        }
        if ($b =~ /[A-Z](\d+)-/) {
            $byear = $1 + 0;
            next unless int($byear) >= $start_year && int($byear) < $to_year;
        }
    }

    if (defined $document_topic{$b}) {
        my @topics = @{$document_topic{$b}};
        my $paper_weight = 1.0;
        foreach (0..$#topics) {
            $topic_weight[$_] += $topics[$_] * $paper_weight;
        }
    } else {
        #print "[warninng] cannot find topic distribution for paper id $b\n";
        $missing_cnt += 1;
    }

    $total_cnt += 1;
}
print OUT join("\n", @topic_weight);
print "MISSING/TOTAL = $missing_cnt / $total_cnt \n";
close OUT;
