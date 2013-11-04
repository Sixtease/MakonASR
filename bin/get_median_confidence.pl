#!/usr/bin/perl

# input: julius recout file
# option: -w: word-level confidence measure [default]
# option: -p: phoneme-level confidence measure

use 5.010;
use strict;
use warnings;
use utf8;

my @score;

my $phonemes = 0;

if ($ARGV[0] eq '-w') { shift @ARGV; }
elsif ($ARGV[0] eq '-p') { $phonemes = 1; shift @ARGV; }

my $in_cm = 0;

while (<>) {
    if ($phonemes) {
        $in_cm = /-- phoneme alignment --/ .. /=== end forced alignment ===/;
    }
    else {
        $in_cm = /-- word alignment --/ .. /=== end forced alignment ===/;
    }
    next unless $in_cm;
    next unless /^\[\s*\d+\s+\d+\s*\]\s+([-\d.]+)/;
    push @score, $1;
}

print("\n"), exit(0) if not @score;
@score = sort @score;
print $score[@score/2], "\n";

__END__
