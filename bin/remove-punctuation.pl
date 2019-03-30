#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

while (<>) {
    s/[^[:alpha:][:blank:]]//g;
    print;
}
