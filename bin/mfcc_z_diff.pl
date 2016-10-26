#!/usr/bin/perl

# Vezme MFCC_0 (arg1) a stejnou nahrávku v MFCC_0_Z (arg2)
# a vyplivne průměry (arg1 - arg2).
# Ty pak můžu odečíst od MFCCčka s přidanými neřečovými událostmi
# a dostat tak správnou normalizaci.

use 5.010;
use strict;
use warnings;
use utf8;

my $LEN = 13;   # number of coefficients
my $BYTES_PER_COEF = 4;
my $HEADER_SIZE = 12;
my $VSIZE = $BYTES_PER_COEF * $LEN;

my ($m0_fn, $mz_fn) = @ARGV;

open my $m0_fh, '<', $m0_fn or die "cannot open first mfcc '$m0_fn': $!";
open my $mz_fh, '<', $mz_fn or die "cannot open second mfcc '$mz_fn': $!";

binmode $m0_fh, ':raw';
binmode $mz_fh, ':raw';

my ($result, $buffer);

$result = read $m0_fh, $buffer, $HEADER_SIZE;
die "read error from $m0_fn: $!" if not defined $result;
die "no header present in $m0_fn" if $result < $HEADER_SIZE;

$result = read $mz_fh, $buffer, $HEADER_SIZE;
die "read error from $mz_fn: $!" if not defined $result;
die "no header present in $mz_fn" if $result < $HEADER_SIZE;

my (@m0_coef, @mz_coef, $avg);

#VECTOR:
#while (1) {
    $result = read $m0_fh, $buffer, $VSIZE;
    die "error reading $m0_fn: $!" if not defined $result;
#    last VECTOR if $result == 0;
    die "file ends inside a vector: $m0_fn" if $result != $VSIZE;
    @m0_coef = unpack "f>$LEN", $buffer;

    $result = read $mz_fh, $buffer, $VSIZE;
    die "error reading $mz_fn: $!" if not defined $result;
    die "file ends inside a vector: $mz_fn" if $result != $VSIZE;
    @mz_coef = unpack "f>$LEN", $buffer;

    my @avg_coef = map {;$m0_coef[$_] - $mz_coef[$_]} 0 .. $#m0_coef;
#    my $joined = join(
#        ' ',
#        map sprintf('%.4e', $_),
#        @avg_coef
#    );

#    if (not $avg) {
#        $avg = $joined;
#        say $avg;
#        next VECTOR;
#    }

#    if ($joined ne $avg) {
#        die "'$avg' and '$joined' differ";
#    }
    say for @avg_coef;
#}
