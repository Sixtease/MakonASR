#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use Encode qw(decode_utf8 encode);

while (<>) {
    my $line = decode_utf8($_);
    my $uc = uc $line;
    print encode 'ISO-8859-2', $uc;
}
