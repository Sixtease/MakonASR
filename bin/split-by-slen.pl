#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use JSON::XS qw(decode_json);

SUBFILE:
for my $fn (@ARGV) {
    my $json = do { local (@ARGV, $/) = $fn; <> };
    $json =~ s/^[^{]+//s;
    $json =~ s/[^}]+$//s;
    
    undef $@;
    my $subs = eval { decode_json($json) };
    if (not $subs) {
        warn "JSON parse failed: $@";
        next SUBFILE;
    }

    my @sils;
    my $sub;
    
    SUB:
    for my $i (0 .. $#{$subs->{data}}) {
        $sub = $subs->{data}[$i];
        my $len = $sub->{slen} - 0; # silence length
        my $start = $sub->{sstart}; # silence start
        my $mid = $start + $len / 2;
        die "long silence (start: $start, length: $len)" if $len > 30;
        push @sils, {
            len => $len,
            mid => $mid,
        };
    }

    $maxi = $#sils;
    for my $i (1 .. $maxi) {
        $sils[$i]{l} = $sils[$i - 1];
    }
    for my $i (0 .. $maxi - 1) {
        $sils[$i]{r} = $sils[$i + 1];
    }

    @sils = sort {$a->{len} <=> $b->{len}} @sils;
}

sub start {
    my ($sub, $subs) = @_;
    $last_sent_start = $sub;
    return "sent$sent_no $subs->{filestem} $sub->{timestamp}"
}
sub end {
    my ($sub) = @_;
    return " .. $sub->{timestamp}\n"
}

sub sentence_boundary {
    my ($last_sub, $sub) = @_;
    my $was_sent_end = $last_sub->{is_sent_end};
    if ($was_sent_end and $sub->{occurrence} =~ /^\W*[[:upper:]]/) {
        return 1
    }
    
    if ($sub->{occurrence} =~ /^ \s* \. \s* [[:upper:]]/x) {
        return 1
    }
    
    my $t = $sub->{timestamp} - $last_sent_start->{timestamp};

    if ($was_sent_end and $last_sent_start and $t > 10) {
        return 1
    }
    
    if ($last_sub->{occurrence} =~ /[,;]\W*$/ and $t > 15) {
        return 1
    }
    
    if ($t > 30) {
        return 1
    }
    return 0
}

