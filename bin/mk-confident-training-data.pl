#!/usr/bin/perl

use strict;
use warnings;
use utf8;

my $mfcc_dir = $ENV{MAKONFM_MFCC_DIR};
my $hcopy_conf = "$ENV{EV_homedir}resources/htk-config-mfcc2mfcc-full";

my $chunk_dir = shift @ARGV;

my $prefix = 'confident';
my $sent_no = '0000000';

while (<>) {
    chomp;
    my ($stem, $start, $end, $phonet) = /^(\S+) ([\d.]+) \.\. ([\d.]+): (.*)/;
    $sent_no++;
    hcopy($stem, $start, $end) or next;
    spit_mlf($phonet);
    die if -e '/tmp/KILLSIG';
}

sub hcopy {
    my ($stem, $start, $end) = @_;
    print STDERR "$stem: $start .. $end => $prefix$sent_no";
    my $err = system qq(HCopy -C "$hcopy_conf" -s ${start}e7 -e ${end}e7 "$mfcc_dir/$stem.mfcc" "$chunk_dir/$prefix$sent_no.mfcc");
    if ($err) {
        print STDERR " failed with $? :-(\n";
        if ($? == 2) { die 'CTRL-C' }
        return 0
    }
    else {
        print STDERR "\n";
        return 1
    }
}

sub spit_mlf {
    my ($phonet) = @_;
    print qq{"*/$prefix$sent_no.lab"\n};
    for (split /\s+/, $phonet) {
        print "$_\n";
    }
    print ".\n";
}
