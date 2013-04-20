#!/usr/bin/perl

use strict;
use warnings;
use utf8;

my @score;

while (<>) {
    next unless /^\[\s*\d+\s+\d+\s*\]\s+([-\d.]+)/;
    push @score, $1;
}

@score = sort @score;
print $score[@score/2], "\n";

__END__
