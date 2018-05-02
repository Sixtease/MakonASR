#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use JSON::XS qw(decode_json);
use Encode qw(encode_utf8);

SUBFILE:
for my $fn (@ARGV) {
    my $json = do { local (@ARGV, $/) = $fn; <> };
    $json =~ s/^[^{]+//s;
    $json =~ s/[^}]+$//s;
    
    undef $@;
    my $subs = eval { decode_json(encode_utf8($json)) };
    if (not $subs) {
        warn "JSON parse failed for $fn: $@";
        next SUBFILE;
    }

    say $subs->{filestem}, ':';

    my @sils;
    my $sub;
    
    SUB:
    for my $i (0 .. $#{$subs->{data}}) {
        $sub = $subs->{data}[$i];
        my $len = $sub->{slen} || 0; # silence length
        my $start = $sub->{sstart}; # silence start
        next SUB if not defined $start;
        my $mid = $start + $len / 2;
        warn "long silence (stem: $subs->{filestem}, start: $start, length: $len)" if $len > 30;
        push @sils, {
            len => $len,
            mid => $mid,
        };
    }
    my $file_end = $subs->{data}[-1]{sstart} + $subs->{data}[-1]{slen};

    my $maxi = $#sils;
    for my $i (1 .. $maxi) {
        $sils[$i]{l} = $sils[$i - 1];
    }
    for my $i (0 .. $maxi - 1) {
        $sils[$i]{r} = $sils[$i + 1];
    }
    $sils[ 0]{l} = { mid => 0 };
    $sils[-1]{r} = { mid => $file_end };

    @sils = sort {$a->{len} <=> $b->{len}} @sils;

    my @kept;
    for my $sil (@sils) {
        if ($sil->{r}{mid} - $sil->{l}{mid} > 60) {
            push @kept, $sil;
        }
        else {
            $sil->{l}{r} = $sil->{r};
            $sil->{r}{l} = $sil->{l};
        }
    }

    for my $point (sort {$a <=> $b} map $_->{mid}, @kept) {
        printf "%.2f\n", $point + 0.0001;
    }

    say '';
}
