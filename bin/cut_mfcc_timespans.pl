#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my $audio_suffix = $ENV{MAKONFM_AUDIO_SUFFIX} || 'wav';
my ($stem, $in_mfcc_dir, $spansdir, $out_mfcc_dir) = @ARGV;

my $spans_fn = "$spansdir/$stem";
open my $spans_fh, '<', $spans_fn or die "couldn't open spans file '$spans_fn': $!";

my $in_mfcc_fn = "$in_mfcc_dir/$stem.mfcc";

my $hconf = "$ENV{EV_homedir}resources/htk-config-mfcc2mfcc";

my @parts;

while (<$spans_fh>) {
    my ($start, $end) = /([.\d]+) \.\. ([.\d]+)/;
    my $out_qfn = qq("$out_mfcc_dir/$stem.$start.mfcc");
    push @parts, $out_qfn;
    system qq(HCopy -C "$hconf" -s ${start}e7 -e ${end}e7 "$in_mfcc_fn" $out_qfn);
}

my $b = 0;
while (@parts > 1) {
    my $stop = ((@parts > 1000) ? 999 : $#parts);
    my @batch = @parts[0 .. $stop];

    my $batch_fn = "$out_mfcc_dir/$stem.batch$b.mfcc";
    $b++;
    splice @parts, 0, $stop+1, $batch_fn;

    my $concat = join ' + ', @batch;
    my $cmd = qq(HCopy -C "$hconf" $concat "$batch_fn");
    system $cmd;

    system "rm @batch";
}
system qq(mv "$parts[0]" "$out_mfcc_dir/$stem.mfcc") if @parts;
