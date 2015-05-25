#!/usr/bin/perl

use strict;
use warnings;
use utf8;

<> eq "#!MLF!#\n" or die "first line was not a MLF header";

LINE:
while (<>) {
    chomp;
    next LINE if /^\s*$/;
    if (/^".*"$/) {
        print '<s> ';
        next LINE;
    }
    if ($_ eq '.') {
        print "</s>\n";
        next LINE;
    }
    print "$_ ";
}
