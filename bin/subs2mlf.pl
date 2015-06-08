#!/usr/bin/perl

# a reduced version of subs2train.pl

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my ($out_mlf_fn) = @ARGV;

open my $mlf_fh, '>:utf8', $out_mlf_fn or die "Couldn't open '$out_mlf_fn': $!";

my $log_fh;
if ($ENV{SUB_EXTRACTION_LOG}) {
    open $log_fh, '>', $ENV{SUB_EXTRACTION_LOG};
}

print {$mlf_fh} "#!MLF!#\n";

$/ = '';
LINE:
while (<STDIN>) {
    my ($head, $sent, $end) = split /\n/;
    my ($sid, $filestem, $start) = split /\s+/, $head;
    
    print {$log_fh} "$filestem $start .. $end => $sid\n" if $log_fh;
    
    print {$mlf_fh} qq("*/$sid.lab"\n);
    $sent =~ s/\s+/\n/g;
    1 while chomp $sent;
    $sent .= "\n.\n";
    print {$mlf_fh} uc $sent;
}
