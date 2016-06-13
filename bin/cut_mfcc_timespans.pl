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

my $concat = join ' + ', @parts;

my $cmd = qq(HCopy -C "$hconf" $concat "$out_mfcc_dir/$stem.mfcc");
system $cmd;

system "rm @parts";
