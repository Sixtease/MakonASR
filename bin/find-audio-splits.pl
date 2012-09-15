#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Audio::FindChunks;
use File::Basename;
use Getopt::Long qw(:config require_order);

my $rmsdir   = $ENV{SPLITDIR};
my $splitdir = $ENV{SPLITDIR};

GetOptions(
    'rmsdir=s'   => \$rmsdir,
    'splitdir=s' => \$splitdir,
);

$rmsdir //= $splitdir;

for my $fn (@ARGV) {
    my $rms = '';
    for (my $threshold = 0.2; (($threshold < 1) && (split(/\n/,$rms) < 30)); $threshold += 0.1) {
        print STDERR "threshold $threshold: $fn\n";
        my $c = Audio::FindChunks->new(
            filename => $fn,
            min_silence_sec => 0.4,
            min_signal_sec => 5,
            threshold_ratio => 0.8,
        );
        {
            local *STDOUT;
            open STDOUT, '>', \$rms;
            $c->output_blocks();
            close STDOUT;
        }
    }
    my (@splits, $last_end, $start, $end, $gap);
    RMSLINE:
    for (split /\n/, $rms) {
        ($start, $end, $gap) = /^ ([\d.]+) \s* =([\d.]+) .*? gap \s* ([\d.]+)/x or next RMSLINE;
        if (not defined $last_end) {
            push @splits, $start;
            next RMSLINE 
        }
        if ($gap < 1) {
            push @splits, $start - $gap/2;
        }
        else {
            push @splits, $last_end, $start;
        }
    } continue {
        $last_end = $end;
    }
    
    my ($bn) = fileparse $fn, qw(.wav .mp3);
    my $rms_fn = "$rmsdir/$bn.rms";
    my $spl_fn = "$splitdir/$bn.txt";
    open my $rms_fh, '>', $rms_fn or die "Couldn't open $rms_fn: $!";
    print {$rms_fh} $rms;
    close $rms_fh;
    open my $spl_fh, '>', $spl_fn or die "Couldn't open $spl_fn $!";
    printf {$spl_fh} "%.2f\n", $_ for @splits;
    close $spl_fh;
    
    print "$fn $spl_fn\n";
}
