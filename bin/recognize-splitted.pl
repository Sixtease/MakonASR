#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Getopt::Long;
use File::Basename;
use lib "$ENV{EV_homedir}/lib", 'lib';
use HTKUtil;
use HTKout2subs;

my $subdir   = $ENV{SUBDIR};
my $tempdir  = $ENV{TEMPDIR};

GetOptions(
    'subdir=s'  => \$subdir,
    'tempdir=s' => \$tempdir,
);

die 'EV_homedir must be set' if not $ENV{EV_homedir};

my ($stem, $chunks_dir) = @ARGV;

my @mfccs = glob("$chunks_dir/*.mfcc");
generate_scp("$tempdir/mfcc.scp", \@mfccs);

my $cmd = qq(julius -h hmms/hmmmodel -filelist "$tempdir/mfcc.scp" -nlr DATA/LM/tg.arpa -nrl DATA/LM/tgb.arpa -v DATA/wordlist/wl-test-phonet -hlist hmms/phones -walign -input mfcfile -fallback1pass);
print STDERR "$cmd\n";
my $err = system($cmd);
die "julius failed with status $err" if $err;
