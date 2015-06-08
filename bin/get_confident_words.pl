#!/usr/bin/perl

# argument #1 is directory with julius recout $stem.recout and splits $stem.splits
# confidence threshold is given by $ENV{CM_THRESHOLD} and defaults to 0.6
# minimum chunk length is given by $ENV{CM_MINLENGTH} and defaults to 1 (in seconds)
# min number of phones is given by $ENV{CM_MINPHONES} and defaluts to 10

use strict;
use warnings;
use utf8;

my $cm_threshold = $ENV{CM_THRESHOLD} || 0.6;
my $cm_minlength = $ENV{CM_MINLENGTH} || 1;
my $cm_minphones = $ENV{CM_MINPHONES} || 10;

my ($recout_dir) = @ARGV;

my @recout_fns = glob("$recout_dir/*.recout");
my @phones;
my @cmscores;
my @starts;
my @ends;
my $stem;
my $sent_no = 0;
my @splits;
my $total_length = 0;

for my $recout_fn (@recout_fns) {
    ($stem = $recout_fn) =~ s/\.recout$//;
    my $splits_fn = "$stem.splits";
    $stem =~ s{^.*/}{};
    print STDERR "$stem\n";
    open my $recout_fh, '<', $recout_fn or next;
    open my $splits_fh, '<', $splits_fn or next;
    
    @splits = ();
    $sent_no = 0;
    while (<$splits_fh>) {
        /([\d.]+)\s*\.\./ and push @splits, $1;
    }
    close $splits_fh;
    
    my $in_wa;
    while (<$recout_fh>) {
        chomp;
        if (/^phseq1:/) {
            s/^phseq1:\s*//;
            @phones = split / \| /;
        }
        if (/^cmscore1:/) {
            s/^cmscore1:\s*//;
            @cmscores = split / /;
        }
        if (/=== begin forced alignment ===/) {
            $in_wa = 1;
            @starts = @ends = ();
        }
        if (/=== end forced alignment ===/) {
            $in_wa = 0;
            process_sentence();
            $sent_no++;
        }
        if ($in_wa and my ($start,$end) = /\[\s*(\d+)\s+(\d+)\s*\]/) {
            push @starts, $start;
            push @ends, $end;
        }
    }
}

print STDERR "total length: $total_length seconds\n";

sub process_sentence {
    if (@phones != @cmscores or @phones != @starts) {
        print "XXX\n@starts\n@cmscores\n", join(' | ', @phones), "\n";
        die "Inconsistent lengths in $stem at $.";
    }
    my ($start, $end, @chunk);
    for my $i (0 .. $#phones) {
        if ($cmscores[$i] >= $cm_threshold) {
            push @chunk, {
                start => $starts[$i],
                end => $ends[$i],
                phonet => $phones[$i],
            };
        }
        elsif (@chunk) {
            process_chunk(\@chunk);
        }
    }
    if (@chunk) {
        process_chunk(\@chunk);
    }
}

sub process_chunk {
    my $chunk = shift;
    my @chunk = @$chunk;
    @$chunk = ();
    return if not @chunk;
    my $length = ($chunk[-1]{end} - $chunk[0]{start}) / 100;
    if ($length < $cm_minlength) {
        return;
    }
    $total_length += $length;
    my @flat_phones;
    for (@chunk) {
        push @flat_phones, split /\s+/, $_->{phonet};
    }
    if (@flat_phones < $cm_minphones) {
        return;
    }
    my $offset = $splits[$sent_no];
    my $start = $chunk[0]{start} / 100 + $offset;
    my $end   = $chunk[-1]{end}   / 100 + $offset;
    print "$stem $start .. $end: @flat_phones\n";
    # TODO: checknout pozici (splits!) a plivat
}
