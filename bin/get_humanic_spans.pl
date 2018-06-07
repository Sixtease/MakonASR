#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Subs qw(decode_subs);
use 5.010;

SUBFILE:
for my $fn (@ARGV) {
    my $json = do { local (@ARGV, $/) = $fn; <> };
    next SUBFILE if not $json =~ /\bhumanic\b/;
    
    my $subs = eval { decode_subs($json) };
    if (not $subs) {
        warn "JSON parse failed: $@";
        next SUBFILE;
    }
    
    # pad end with a fake non-humanic subtitle
    push @{ $subs->{data} }, { timestamp => 9999.99, occurrence => '' };
    my $last_sub = {is_sent_end => 0, occurrence => ''};
    
    my $was_humanic = 0;
    
    SUB:
    while (my ($i, $sub) = each (@{ $subs->{data} })) {
        my $is_humanic = $sub->{humanic};
        if ($is_humanic && !$was_humanic) {
            print $subs->{filestem}, ' ', $sub->{timestamp}, ' ';
        }
        elsif (!$is_humanic && $was_humanic) {
            print $sub->{timestamp}, "\n";
        }
        $was_humanic = $sub->{humanic};
    }
}
