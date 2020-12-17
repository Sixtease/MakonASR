#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my $threshold_ratio = shift;
my $abs_threshold = -4;

while (<>) {
  my ($log_likelihood_makon, $log_likelihood_wmt, $sentence) = split / /, $_, 3;
  print $sentence if $log_likelihood_makon > $abs_threshold and $log_likelihood_wmt < log($threshold_ratio) + $log_likelihood_makon;
}
