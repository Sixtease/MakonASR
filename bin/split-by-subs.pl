#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use JSON ();

my $sent_no = '00000';
my $is_sent_end = 0;
my $last_sent_start;

SUBFILE:
for my $fn (@ARGV) {
    my $json = do { local (@ARGV, $/) = $fn; <> };
    $json =~ s/^[^{]+//;
    $json =~ s/[^}]+$//;
    
    undef $@;
    my $subs = eval { JSON->new->decode($json) };
    if (not $subs) {
        warn "JSON parse failed: $@";
        next SUBFILE;
    }
    
    # pad end with a stop subtitle
    my $last_sub = {is_sent_end => 0, occurrence => ''};
    
    SUB:
    for my $i (0 .. $#$subs->{data}) {
        my $sub = $subs->{data}[$i];
        $sub->{is_sent_end} = $sub->{occurrence} =~ /[.!?:;]\W*$/;
        if ($i == 0) {
            print start($sub, $subs);
            $sent_no++;
            next SUB
        }
        if ($i == $#{$subs->{data}}) {
            print end($sub);
            next SUB
        }
        if (sentence_boundary($last_sub, $sub)) {
            print end($sub);
            print start($sub, $subs);
            $sent_no++;
            next SUB
        }
    } continue {
        $last_sub = $sub;
    }
    undef $last_sent_start;
}

sub start {
    my ($sub, $subs) = @_;
    $last_sent_start = $sub;
    return "sent$sent_no $subs->{filestem} $sub->{timestamp}"
}
sub end {
    my ($sub) = @_;
    return" .. $sub->{timestamp}\n"
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
