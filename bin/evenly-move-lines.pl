#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my ($cnt, $sample_fn, $residuum_fn, $source_fn) = @ARGV;

my $total_lines = `wc -l "$source_fn"` - 0;
my $modulus = int($total_lines / $cnt);

open my $source_fh,   '<', $source_fn   or die;
open my $sample_fh,   '>', $sample_fn   or die;
open my $residuum_fh, '>', $residuum_fn or die;

my $i = 0;
while (<$source_fh>) {
    $i++;
    if ($i % $modulus) {
        print {$residuum_fh} $_;
    }
    else {
        print {$sample_fh} $_;
    }
}
