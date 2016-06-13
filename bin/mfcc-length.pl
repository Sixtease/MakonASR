#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use HTKUtil::MfccLib qw(mfcc_header);

my ($mfcc_fn) = @ARGV;
my $header = mfcc_header($mfcc_fn);

printf "%.2f\n", $header->{length};
