#!/usr/bin/perl

use strict;
use warnings;
use utf8;

my $makefile = 'bin/MakeCorpus2LM';
my $unig = 'temp/unigram.csv';

system(qq(make -f "$makefile" "$unig"));

my $wtotal = (stat($unig))[7];

mkvoc('DATA/wALL', $wtotal);
for (my $w = 1000; $w < $wtotal; $w+=1000) {
    mkvoc("DATA/w$w", $w);
}

system(qq(add-phones.sh "hmms/phones" "$ENV{EV_wordlist_test_phonet}"));

sub mkvoc {
    my ($dir, $cnt) = @_;
    $ENV{EV_vocab_size} = $cnt;
    $ENV{EV_wl_test} = "$dir/WORDLIST-test";
    $ENV{EV_wordlist_test_phonet} = "$dir/wl-test-phonet";
    $ENV{EV_LMf} = "$dir/tg.arpa";
    $ENV{EV_LMb} = "$dir/tgb.arpa";
    
    system(qq(make -f "$makefile" "$ENV{EV_LMf}"));
    system(qq(make -f "$makefile" "$ENV{EV_wordlist_test_phonet}"));
}
