#!/usr/bin/perl

use strict;
use warnings;
use utf8;

my $voc_size = shift @ARGV;

my %dict;
my $i = 1;

while (<>) {
    if ($dict{$_}++) { }
    else {
        print;
        last if ++$i > $voc_size;
    }
}
