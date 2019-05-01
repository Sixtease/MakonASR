#!/usr/bin/perl

# mimics split-by-subs.pl
# but works when there is not subs file;
# given a path, extracts the stem from it
# and figures out the corresponding MFCC filename

use 5.010;
use strict;
use warnings;
use utf8;
use HTKUtil::MfccLib qw(mfcc_header);
use File::Basename qw(fileparse);

my $chunk_length = $ENV{MAKONFM_NAIVE_SPLIT_CHUNK_LENGTH} || 15;

for my $fn (@ARGV) {
    my $stem;
    my $mfcc_fn;
    if ($fn =~ /\.mfcc$/) {
        $mfcc_fn = $fn;
        $stem = fileparse($fn, '.mfcc');
    }
    elsif ($fn =~ /\.sub.js$/) {
        $stem = fileparse($fn, '.sub.js');
        $mfcc_fn = $ENV{MFCCDIR} . '/' . $stem . '.mfcc';
        die "mfcc file '$mfcc_fn' des not exist" if not -e $mfcc_fn;
    }
    my $header = mfcc_header($mfcc_fn);
    my $total_length = $header->{length};
    my $chunks_cnt = int($total_length / $chunk_length);
    if ($chunks_cnt > 1 and $total_length % $chunk_length < ($chunk_length / 2)) {
        $chunks_cnt--;
    }
    my $sent_no = '00000';
    for (1 .. $chunks_cnt) {
        printf(
            "sent%s %s %.2f .. %.2f\n",
            $sent_no++,
            $stem,
            ($_-1) * $chunk_length,
            ($_ == $chunks_cnt ? $total_length : $_*$chunk_length),
        );
    }
}
