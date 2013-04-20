#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Getopt::Long;
use File::Slurp;
use File::Basename;

my $prefix = '';
GetOptions(
    'prefix=s' => \$prefix,
);

print "#!MLF!#";
for (glob("@ARGV")) {
    my $f = read_file($_);
    my $bn = basename $_;
    print qq(\n"*/$prefix$bn");
    chomp $f;
    $f =~ s/\s+/\n/g;
    print "\n$f";
}
