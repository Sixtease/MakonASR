#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;

my $threshold = shift;

while (<>) {
  my ($log_likelihood, $sentence) = split / /, $_, 2;
  print $sentence if $log_likelihood >= $threshold;
}
