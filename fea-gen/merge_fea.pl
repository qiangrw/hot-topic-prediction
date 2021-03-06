#!/usr/bin/perl -w
# @author: Runwei Qiang 
# @create: 2015-5-2
# @descrption: paper score to topic feature
use strict;

my $usage = "perl $0 year matrix_file output\n";
my $year = shift @ARGV or die $usage;
my $matrix = shift @ARGV or die $usage;
my $output = shift @ARGV or die $usage;

print "loading labels\n";
my $label_file = "../label-gen/label$year";
open FH, $label_file or die $!;
my @labels = <FH>;
chomp(@labels);
close FH;

print "loading matrix\n";
my %document_topic;
my $topic_no = 0;
open MR, $matrix or die $!;
while (<MR>) {
    chomp;
    my ($pid, @topics) = split /\t/;
    foreach (0..$#topics) {
        if ($topics[$_] =~ m/nan/i) {
            $topics[$_] = 0;
        }
    }
    $document_topic{$pid} = \@topics;
    $topic_no = scalar @topics;
}
close MR;

print "topic no: $topic_no\n";
my @topic_features;
foreach (0..$#labels) {
    $topic_features[$_] = substr($labels[$_], 0, 1) . " qid:1 ";
}

#push @topic_features, "" foreach (@labels);

my @files = glob ("score/year$year*");
my $feature_idx = 1;
foreach (@files) {
    print "prcess score file : $_\n";
    
    my @topic_weight;
    print "$topic_no topics detected\n";
    $topic_weight[$_] = 0 foreach(0..$topic_no-1);

    open FH, $_ or die $!;
    while (<FH>) {
        chomp;
        my ($pid, $score) = split /\s+/;
        if (defined $document_topic{$pid}) {
            my @topics = @{$document_topic{$pid}};
            foreach (0..$#topics) {
                $topic_weight[$_] += $topics[$_] * 1.0 * $score;
            }
        } 
    }

    foreach (0..$#topic_features) {
        $topic_features[$_] .= ($feature_idx) . ":" . $topic_weight[$_] . " "
    }
    $feature_idx += 1;

    close FH;
}

# add label
open OUT, ">$output" or die $!;
foreach (0..$#topic_features) {
    print OUT $topic_features[$_], "# Topic ", $_ + 1, "\n";
}
close OUT;
