#!/usr/bin/perl

use strict;
use warnings;
use utf8;

my $voc_size = shift @ARGV;

my %dict;
my $i = 0;

while (<>) {
    if ($dict{$_}++) { }
    else {
        print;
    }
    last if ++$i > $voc_size;
}
