#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my ($hconf, $wildcard, $outfile) = @ARGV;

my @files = glob($wildcard);

my @args = (
    '-C', $hconf,
    shift(@files),
    (map {;('+', $_)} @files),
    $outfile,
);

system ('HCopy', @args);
