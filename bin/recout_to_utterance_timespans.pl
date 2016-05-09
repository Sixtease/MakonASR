#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use JulLib ();
use File::Basename qw(basename);

my $splits_dir = shift @ARGV;
my $outdir = shift @ARGV;

while (@ARGV) {
    my $recout_fn = shift @ARGV;
    my $stem = basename $recout_fn;
    print STDERR "*** $stem ***\n";
    my $splits_fn = "$splits_dir/$stem/chunks/splits";
    close STDOUT;
    open STDOUT, '>', "$outdir/$stem";
    JulLib::recout_to_utterance_timespans($recout_fn, $splits_fn);
}
