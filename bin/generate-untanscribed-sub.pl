#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use Subs qw(encode_subs);

my ($fn, $stem) = @ARGV;

die "Usage: $0 audio.flac stem > stem.sub.js" if @ARGV != 2;

my $len = `soxi -D $fn`;

die "Could not determine positive length of $fn" if not $len > 0;

my @data;
my $pos = 0;
while ($pos < $len) {
    if ($pos / 60 == int $pos / 60) {
        push @data, word(hms($pos), $pos);
    }
    elsif ($pos / 10 == int $pos / 10) {
        push @data, word('|', $pos);
    }
    elsif ($pos == int $pos) {
        push @data, word('-', $pos);
    }
    else {
        push @data, word('.', $pos);
    }
} continue {
    $pos += 0.25;
}

print encode_subs(\@data, $stem);

sub hms {
    my ($secs) = @_;
    if ($secs < 60) {
        return int $secs;
    }
    my $s = sprintf '%02d', $secs % 60;
    my $mins = int $secs / 60;
    my $m = sprintf '%02d', $mins % 60;
    if ($mins < 60) {
        return "$m:$s";
    }
    my $h = int $mins / 60;
    return "$h:$m:$s";
}

sub word {
    my ($form, $timestamp) = @_;
    return {
        timestamp => $timestamp,
        fonet => 'sil',
        occurrence => "$form",
        wordform => "$form",
        cmscore => 0,
    };
}
