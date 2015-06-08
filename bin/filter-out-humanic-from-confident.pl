#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use feature 'say';

sub start() { return 0 }
sub end  () { return 1 }

my ($humanic_fn) = shift @ARGV;

my %hum;
open my $humanic_fh, '<', $humanic_fn or die;
while (<$humanic_fh>) {
    my ($stem, $start, $end) = split /\s+/;
    push @{ $hum{$stem} }, [$start, $end];
}
close $humanic_fh;

while (<>) {
    my ($stem, $start, $end) = /^(\S+) ([\d.]+) \.\. ([\d.]+):/ or print(), next;
    next if is_hum($stem, $start, $end);
    print;
}

sub is_hum {
    my ($stem, $rec_start, $rec_end) = @_;
    return 0 if not exists $hum{$stem};
    my $last_hum;
    my $next_hum;
    for my $hum (@{ $hum{$stem} }) {
        if ($hum->[start] > $rec_start) {
            $next_hum = $hum;
            last;
        }
        $last_hum = $hum;
    }
    if ($last_hum and $last_hum->[end] > $rec_start) { return 1 }
    if ($next_hum and $next_hum->[start] < $rec_end) { return 1 }
    return 0
}
