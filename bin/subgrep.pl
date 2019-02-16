#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use File::Basename qw(dirname);
my $PATH = sub { dirname((caller)[1]) }->();

my @passed_opts;
if ($ARGV[0] eq '-w') {
    @passed_opts = shift @ARGV;
}
my $query = shift @ARGV;

for my $fn (@ARGV) {
    my $text = `$PATH/sub2text.pl @passed_opts "$fn"`;
    if (my $match = $text =~ /$query/) {
        say "$fn: $match";
    }
}
