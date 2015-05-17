#!/usr/bin/perl -w
use strict;

my $usage = "perl $0 to_year (2011/2012)\n";

my $year = shift @ARGV or die $usage;
die $usage unless $year == 2011 || $year == 2012;
my $start_year = $year == 2011 ? 1 : 2;     # 2001 / 2002
my $end_year = $year == 2011 ? 10 : 11 ;    # 2011 / 2012

open META, "../release/2013/acl-metadata.txt";
open POUT, ">paper2authors.$year.txt";
my %paper2authors;
while (my $id_string = <META>) {
    my ($id, @authors);
    if ($id_string =~ m/id\s+=\s+\{(.*)\}/) {
        $id = $1;
    }
    my $author_string = <META>;
    if ($author_string =~ m/author\s+=\s+\{(.*)\}\s*/) {
        @authors = split /\s*;\s*/, $1;
    }
    <META>;  # title
    <META>;  # venue

    my $year_string = <META>;  # year
    <META>;  # empty line


    if ($year_string =~ m/year\s+=\s+\{20(.*)\}/) {
        my $pyear = $1 + 0;
        next unless int($pyear) >= $start_year && int($pyear) <= $end_year;
    } else {
        next;
    }
    
    $paper2authors{$id} = \@authors;
    print POUT "$id\t", join("\t", @authors), "\n";
}
close POUT;
close META;
print "meta data loaded\n";


open ACL, "../release/2013/acl.txt";
open NOUT, ">author_citation.$year.txt";

my %article2id;
my @articles;
my $idx = 0;
my ($a, $b, $ayear, $byear);
while (<ACL>) {
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
        next unless defined $paper2authors{$a};
        next unless defined $paper2authors{$b};

        my @authors_a = @{$paper2authors{$a}};
        my @authors_b = @{$paper2authors{$b}};
        print NOUT "$authors_a[0]  ==> $authors_b[0]\n";
=cutforeach my $aa (@authors_a) {
            foreach my $ab (@authors_b) {
                print NOUT "$aa ==>  $ab\n";
            }
        }
=cut
    }
}
close NOUT;
close ACL;

