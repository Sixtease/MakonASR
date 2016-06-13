#!/usr/bin/perl

# Vezme MFCC_0 (arg1) a průměrné koeficienty (arg2)
# a vyplivne MFCC_Z.

use 5.010;
use strict;
use warnings;
use utf8;

my $LEN = 13;   # number of coefficients
my $BYTES_PER_COEF = 4;
my $HEADER_SIZE = 12;
my $VSIZE = $BYTES_PER_COEF * $LEN;

my ($m0_fn, $avg_fn, $outfn) = @ARGV;

open my $m0_fh,  '<', $m0_fn or die "cannot open first mfcc '$m0_fn': $!";
open my $avg_fh, '<', $avg_fn or die "cannot open second mfcc '$avg_fn': $!";
open my $outfh,  '>', $outfn or die "cannot open output file '$outfn': $!";

binmode $m0_fh, ':raw';
binmode $outfh, ':raw';

my @avg = <$avg_fh>;
chomp for @avg;
die "unexpected number of averaged coefficients (expected $LEN-1 or $LEN): @avg"
    if @avg < $LEN-1 or @avg > $LEN;

#$avg[$LEN-1] = 0;   # don't normalize 0th coefficient (residing on index 12)

my ($result, $buffer);

$result = read $m0_fh, $buffer, $HEADER_SIZE;
die "read error from $m0_fn: $!" if not defined $result;
die "no header present in $m0_fn" if $result < $HEADER_SIZE;
print {$outfh} $buffer; # pass header

VECTOR:
while (1) {
    $result = read $m0_fh, $buffer, $VSIZE;
    die "error reading $m0_fn: $!" if not defined $result;
    last VECTOR if $result == 0;
    die "file ends inside a vector: $m0_fn" if $result != $VSIZE;
    my @m0_coef = unpack "f>$LEN", $buffer;

    my @z_coef = map {;$m0_coef[$_] - $avg[$_]} 0 .. $#m0_coef;

    my $packed = pack "f>$LEN", @z_coef;

    print {$outfh} $packed;
}
