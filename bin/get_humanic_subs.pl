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
    next SUBFILE if not $json =~ /\bhumanic\b/;
    $json =~ s/^[^{]+//;
    $json =~ s/[^}]+$//;
    
    undef $@;
    my $subs = eval { JSON->new->decode($json) };
    if (not $subs) {
        warn "JSON parse failed: $@";
        next SUBFILE;
    }
    
    # pad end with a fake non-humanic subtitle
    push $subs->{data}, { timestamp => 9999.99, occurrence => '' };
    my $last_sub = {is_sent_end => 0, occurrence => ''};
    
    SUB:
    for my $sub (@{ $subs->{data} }) {
        my $is_humanic = ($sub->{humanic} .. !$sub->{humanic}) || 0;
        next if not $is_humanic;
        $sub->{is_sent_end} = $sub->{occurrence} =~ /[.!?:;]\W*$/;
        if ($is_humanic == 1) {
            print start($sub, $subs);
            $sent_no++;
            next SUB
        }
        if (substr($is_humanic, -2) eq 'E0') {
            print end($sub);
            next SUB
        }
        if (sentence_boundary($last_sub, $sub)) {
            print end($sub);
            print start($sub, $subs);
            $sent_no++;
            next SUB
        }
        print ' ', $sub->{wordform};
    } continue {
        $last_sub = $sub;
    }
    undef $last_sent_start;
}

sub start {
    my ($sub, $subs) = @_;
    $last_sent_start = $sub;
    return "sent$sent_no $subs->{filestem} $sub->{timestamp}\n$sub->{wordform}"
}
sub end {
    my ($sub) = @_;
    return"\n$sub->{timestamp}\n\n"
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
    
    if ($t > 60) {
        return 1
    }
    return 0
}
