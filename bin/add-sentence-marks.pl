#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my $start_mark = $ENV{SENTENCE_START_MARK} // '<s>';
my $stop_mark  = $ENV{SENTENCE_STOP_MARK}  // '</s>';

while (<>) {
    chop;
    say "$start_mark $_ $stop_mark";
}
