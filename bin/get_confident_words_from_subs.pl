#!/usr/bin/perl

# argument #1 is directory with julius recout $stem.recout and splits $stem.splits
# confidence threshold is given by $ENV{CM_THRESHOLD} and defaults to 0.6
# minimum chunk length is given by $ENV{CM_MINLENGTH} and defaults to 1 (in seconds)
# min number of phones is given by $ENV{CM_MINPHONES} and defaluts to 10

use strict;
use warnings;
use utf8;
use 5.010;
use Subs qw(decode_subs);

my $cm_threshold = $ENV{CM_THRESHOLD} || 0.6;
my $cm_minlength = $ENV{CM_MINLENGTH} || 1;
my $cm_minphones = $ENV{CM_MINPHONES} || 10;

my ($sub_dir) = @ARGV;

my @sub_fns = glob("$sub_dir/*.sub.js");
my $stem;
my $sent_no = 0;
my $chunk_start;
my $chunk_end;
my @phones;
my $total_length = 0;

for my $sub_fn (@sub_fns) {
    my $subs = decode_subs($sub_fn);
    $stem = $subs->{filestem};
    if (not $stem) {
        warn "no filestem for $sub_fn";
        next;
    }
    print STDERR "$stem\n";

    $sent_no = 0;
    
    for my $sub (@{ $subs->{data} }) {
        if ($sub->{cmscore} >= $cm_threshold) {
            if (@phones == 0) {
                $chunk_start = $sub->{timestamp};
            }
            push @phones, $sub->{fonet};
        }
        elsif (@phones) {
            $chunk_end = $sub->{timestamp};
            process_chunk();
            @phones = ();
        }
    }
}

print STDERR "total length: $total_length seconds\n";

sub process_chunk {
    return if not @phones or not $chunk_start or not $chunk_end;
    my $length = $chunk_end - $chunk_start;
    if ($length < $cm_minlength) {
        return;
    }
    $total_length += $length;
    my @flat_phones = map { split / / } @phones;
    if (@flat_phones < $cm_minphones) {
        return;
    }
    print "$stem $chunk_start .. $chunk_end: @flat_phones\n";
}

