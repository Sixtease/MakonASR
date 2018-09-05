#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my @wildcards = @ARGV;

for my $wc (@wildcards) {
    my @fns = glob $wc;
    for my $fn (@fns) {
        my ($stem, $start, $end, $suf) = $fn =~ /^(.+)--from-(.+)--to-(.+)\.([^.]+)$/;
        if (($end - $start) > 120) {
            say $fn;
        }
    }
}
