#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use File::Basename qw(basename);

my $phonemes = 0;

if    ($ARGV[0] eq '-w') { shift @ARGV; }
elsif ($ARGV[0] eq '-p') { $phonemes = 1; shift @ARGV; }

my $in_cm = 0;
my $y = '';
my $last_y = '';

my %y2cm;

while (<ARGV>) {
    my $bn = basename($ARGV);
    next unless $bn =~ /^(\d{2})-/;
    if ($y ne $last_y) {
        say STDERR $y;
        $last_y = $y;
    }
    $y = $1;
    if ($phonemes) {
        $in_cm = /-- phoneme alignment --/ .. /=== end forced alignment ===/;
    }
    else {
        $in_cm = /-- word alignment --/ .. /=== end forced alignment ===/;
    }
    next unless $in_cm;
    next unless /^\[\s*\d+\s+\d+\s*\]\s+([-\d.]+)/;
    push @{ $y2cm{$y} }, $1;
}

print $_, ' ', med($y2cm{$_}), "\n" for sort {$a<=>$b} keys %y2cm;

sub med {
    my ($arr) = @_;
    return $arr->[scalar(@$arr)/2]
}
