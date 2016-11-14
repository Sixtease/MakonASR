#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use JSON::XS ();
use File::Basename qw(basename);

my $for_lm = $ENV{BUILDING_LM} || 0;

my %blacklist;
if ($for_lm and $ENV{EV_word_blacklist}) {
    if (open my $blacklist_fh, '<', $ENV{EV_word_blacklist}) {
        while (<$blacklist_fh>) {
            chomp;
            $blacklist{$_} = 1;
        }
    }
}

my $sent_no = '00000';
my $is_sent_end = 0;
my $last_sent_start;

SUBFILE:
for my $fn (@ARGV) {
    if ($for_lm or -e "$ENV{MAKONFM_SUB_DIR}/" . basename($fn)) {} else { next }   # skip subs whom we have no MFCC for
    my $json = do { local (@ARGV, $/) = $fn; <> };
    if ($for_lm and ($ENV{LM_include_nonhumanic_subs} or $ENV{LM_nonhumanic_only})) { } else {
        next SUBFILE if not $json =~ /\bhumanic\b/;
    }
    $json =~ s/^[^{]+//;
    $json =~ s/[^}]+$//;
    
    undef $@;
    my $subs = eval { JSON::XS->new->decode($json) };
    if (not $subs) {
        warn "JSON parse failed: $@";
        next SUBFILE;
    }
    
    # pad end with a fake non-humanic subtitle
    my $end_pad = { timestamp => 9999.99, occurrence => '' };
    if ($ENV{LM_nonhumanic_only}) {
        $end_pad->{humanic} = 1;
    }
    push $subs->{data}, $end_pad;
    my $last_sub = {is_sent_end => 0, occurrence => ''};
    
    SUB:
    while (my ($i, $sub) = each (@{ $subs->{data} })) {
        my $is_humanic;
        if ($ENV{LM_include_nonhumanic_subs}) {
            $is_humanic = ($sub .. $sub == $end_pad) || 0;
        }
        elsif ($ENV{LM_nonhumanic_only}) {
            $is_humanic = (!$sub->{humanic} .. $sub->{humanic}) || 0;
        }
        else {
            $is_humanic = ($sub->{humanic} .. !$sub->{humanic}) || 0;
        }
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
        
        if ($for_lm) {
            if ($blacklist{ uc($sub->{wordform}) }) {
                next SUB
            }
            if ($sub->{occurrence} =~ /\b-$/) {
                next SUB
            }
            if ($sub->{occurrence} =~ /\.\.\.$/) {
                my $lookahead = $subs->{data}[$i+1];
                if ($lookahead and $lookahead->{occurrence} !~ /^\W*[[:upper:]]/ and $lookahead->{humanic}) {
                    next SUB
                }
            }
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
