#!/usr/bin/perl

use strict;
use warnings;
use utf8;

<> eq "#!MLF!#\n" or die "first line was not a MLF header";

my %words;

LINE:
while (<>) {
    chomp;
    next LINE if /^".*"$/;
    next LINE if $_ eq '.';
    $words{$_}++;
}

print "<s>\n</s>\n";
print "$_\n" for sort {$words{$b} <=> $words{$a}} keys %words;
