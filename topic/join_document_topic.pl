#!/usr/bin/perl -w
# @author Runwei Qiang
# @create 2015-05-05
# @description: join document topic distribution

my $usage = "perl $0 training_data matrix\n";
my $train = shift @ARGV or die $usage;
my $matrix = shift @ARGV or die $usage;

open TR, $train or die $!;
open MA, $matrix or die $!;

my $lineno = 1;
while (<TR>) {
    chomp;
    my ($id, $year, $title, $other) = split /,/;
    die "format error" unless $id == $lineno;
    $pid = substr($_, rindex($_, ",") + 1, -1);
    my $line = <MA>;
    chomp($line);
    my ($id2, @line_topic) = split /,/, $line;
    die "id mismatch" unless $id == $id2;
    print "$pid\t";
    print join("\t", @line_topic), "\n";
    
    $lineno += 1;
}

close MA;
close TR;
