#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use 5.010;
use Encode qw(decode_utf8 encode);

my $enc = $ENV{EV_encoding};

my $dict_fn = shift;
my $corpus_fn = shift;

open my $corpus_fh, '>', $corpus_fn or die "Couldn't open '$corpus_fn' for writing: $!";

my %dict;
{
    local $/ = '';
    while (<>) {
        my ($head, $line_bytes, $foot) = split /\n/;
        my $line = decode_utf8($line_bytes);
        my $line_uc = uc $line;
        my @words = split /\s+/, $line_uc;
        $dict{$_}++ for @words;
        say {$corpus_fh} encode($enc, $line_uc);
    }
}

close $corpus_fh;

open my $dict_fh, '>', $dict_fn or die "Couldn't open '$dict_fn' for writing: $!";
print {$dict_fh} encode($enc, "$_\n") for sort {$dict{$b} <=> $dict{$a}} grep {;$dict{$_} > 1} keys %dict;
close $dict_fh;
