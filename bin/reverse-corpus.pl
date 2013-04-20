#!/usr/bin/perl

use strict;
use warnings;
use utf8;

while (<>) {
    chomp;
    my ($start, @words) = split / /;
    my $end = pop @words;
    print join(' ', $start, reverse(@words), $end), "\n";
#    print join(' ', reverse split / /), "\n";
}
