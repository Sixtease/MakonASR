#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use utf8;
use lib qw(/home/sixtease/skola/phd/webapp/MakonFM/lib);
use MakonFM::Util::Subs;
use List::Util qw(sum);

SUB:
for my $fn (@ARGV) {
    my $sub = MakonFM::Util::Subs::get_subs_from_filename($fn);
    next SUB if not ref $sub;
    next SUB if not $sub->{data};
    my @cmscores;
    for my $word (@{ $sub->{data} }) {
        if (exists $word->{cmscore}) {
            push @cmscores, $word->{cmscore};
        }
    }
    if (@cmscores) {
        my $mean = sum(@cmscores) / @cmscores;
        my $median = (sort(@cmscores))[int(@cmscores / 2)];
        say join(' ', $sub->{filestem}, $mean, $median);
    }
    say STDERR $sub->{filestem};
}
