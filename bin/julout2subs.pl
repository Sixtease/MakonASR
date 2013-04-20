#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Encode qw(encode_utf8);
use File::Basename qw(dirname);
my $PATH;
BEGIN { $PATH = sub { dirname( (caller)[1] ) }->(); }
use lib "$PATH/../lib";
use lib "$ENV{EV_homedir}/lib";
use Julout2subs;

my $splits_fn = shift;
my $stem = shift;

print encode_utf8(Julout2subs::convert(\*STDIN, $splits_fn, $stem));
