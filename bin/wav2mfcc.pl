#!/usr/bin/perl

# Preparation:
# 1. create recout files
#   export RECOUT_ONLY=1
#   export RECOUTDIR=...
#   . config.sh
#   batch-apply.sh ~/dokumenty/skola/phd/webapp/MakonFM/root/static/subs/*.sub.js

use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my ($wavdir, $mfccdir) = @_;

while (defined (my $wavfn = glob("$wavdir/*"))) {
    
}
