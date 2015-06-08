#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my $cnt = shift @ARGV;
my $outfile_pattern = shift @ARGV;
die 'Need count of parts as first arg' if not $cnt > 0;
die 'Need output filename pattern ("*" for index)' if length $outfile_pattern == 0 or $outfile_pattern !~ /\*/;

my @outfhs;
for my $i (1 .. $cnt) {
    (my $fn = $outfile_pattern) =~ s/\*/$i/g;
    open my $fh, '>', $fn or die "Couldn't open output file '$fn'";
    push @outfhs, $fh;
}

my $header = <>;
print {$_} $header for @outfhs;
my $i = 0;
while (<>) {
    print {$outfhs[$i]} $_;
} continue {
    if (/^\.\Z/) {
        $i = ($i + 1) % scalar(@outfhs);
    }
}
