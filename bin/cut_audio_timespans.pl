#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my $audio_suffix = $ENV{MAKONFM_AUDIO_SUFFIX} || 'wav';
my ($stem, $wavdir, $spansdir, $outdir) = @ARGV;

my $spans_fn = "$spansdir/$stem";
open my $spans_fh, '<', $spans_fn or die "couldn't open spans file '$spans_fn': $!";

my @cuts;

while (<$spans_fh>) {
    my ($start, $end) = /([.\d]+) \.\. ([.\d]+)/;
    push @cuts, "=$start", "=$end";
}

my $in_wav_fn  = "$wavdir/$stem.$audio_suffix";
my $out_wav_fn = "$outdir/$stem.$audio_suffix";

my $cmd = qq(sox "$in_wav_fn" "$out_wav_fn" trim @cuts);
print "cmd: $cmd\n";
system $cmd;
