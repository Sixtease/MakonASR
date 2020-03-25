#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use 5.010;
use open qw(:std :utf8);
use Encode qw(encode_utf8);
use Subs qw(decode_subs);

my ($start_pos, $end_pos, $subfn) = @ARGV;

my $json = encode_utf8 do { local (@ARGV, $/) = $subfn; <> };

my $subs = eval { decode_subs($json) };

die "JSON parse failed: $@" if not $subs;

SUB:
while (my ($i, $sub) = each (@{ $subs->{data} })) {
    my $ts = $sub->{timestamp};
    next SUB if $ts < $start_pos or $ts > $end_pos;
    print $sub->{occurrence}, ' ';
}
