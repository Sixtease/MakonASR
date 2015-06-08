#!/usr/bin/perl

# HMM was trained for a phone set. The wordlist we want to use for recognition
# has other triphones in it. Add the unknown phones to the phone list.
# params: phones of HMM, phonetic wordlist. Prints to STDOUT.

use 5.010;
use strict;
use warnings;
use utf8;

my $phones_fn = shift;

my %phones;
my ($logical, $physical);
{
    local @ARGV = ($phones_fn);
    while (<ARGV>) {
        my ($p1, $p2) = split /\s+/;
        if ($p2) {
            ($logical, $physical) = ($p1, $p2);
        }
        else {
            ($logical, $physical) = ($p1, $p1);
        }
        $phones{$logical} = $physical;
    }
}

while (<>) {
    (undef, my @phones) = split /\s+/;
    unshift @phones, undef;
    while (@phones > 1) {
        my ($l, $c, $r) = @phones[0,1,2];

        my $full_phone;
        if ($l and $r) {
            $full_phone = "$l-$c+$r";
        }
        elsif ($l) {
            $full_phone = "$l-$c";
        }
        elsif ($r) {
            $full_phone = "$c+$r";
        }
        else {
            $full_phone = "$c";
        }

        my $physical;
        if ($phones{$full_phone}) {
            # all OK, got this one
        }
        elsif ($l and $physical = $phones{"$l-$c"}) {
            $phones{$full_phone} = $physical;
        }
        elsif ($r and $physical = $phones{"$c+$r"}) {
            $phones{$full_phone} = $physical;
        }
        elsif ($physical = $phones{"$c"}) {
            $phones{$full_phone} = $physical;
        }
        else {
            die "monophone $c unknown";
        }
    } continue { shift @phones }
}

print $_ eq $phones{$_} ? "$_\n" : "$_ $phones{$_}\n" for sort {$phones{$a} cmp $phones{$b} or $a cmp $b} keys %phones;
