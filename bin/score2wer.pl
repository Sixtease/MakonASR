#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my ($s, $d, $i, $n);

while (<>) {
    /S=(\d+)/ and $s = $1;
    /D=(\d+)/ and $d = $1;
    /I=(\d+)/ and $i = $1;
    /N=(\d+)/ and $n = $1;
    if ($s and $d and $i and $n) {
        say 100 * ($s + $d + $i) / $n;
        undef $_ for $s, $d, $i, $n;
    }
}
