#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

if ($ARGV[0] eq '-w') {
    shift @ARGV;
    while (<>) {
        if (/wordform\b[^:]*:\s*"(.*)"/) {
            print "$1 ";
        }
    }
}
else {
    while (<>) {
        if (/occurrence\b[^:]*:\s*"(.*)"/) {
            my $occ = $1;
            $occ =~ s/\\(.)/$1/g;
            print "$occ ";
        }
    }
}
