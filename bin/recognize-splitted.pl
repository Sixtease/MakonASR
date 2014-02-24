#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Getopt::Long;
use File::Basename;
use lib "$ENV{EV_homedir}/lib", 'lib';
use HTKUtil;
use HTKout2subs;

my $subdir  = $ENV{SUBDIR};
my $tempdir = $ENV{TEMPDIR};
my $lmf     = $ENV{EV_LMf};
my $lmb     = $ENV{EV_LMb};
my $wl      = 'DATA/wordlist/wl-test-phonet';

GetOptions(
    'subdir=s'   => \$subdir,
    'tempdir=s'  => \$tempdir,
    'lmf=s'      => \$lmf,
    'lmb=s'      => \$lmb,
    'wordlist=s' => \$wl,
);

die 'EV_homedir must be set' if not $ENV{EV_homedir};

my ($stem, $chunks_dir) = @ARGV;

my @mfccs = glob("$chunks_dir/*.mfcc");
generate_scp("$tempdir/mfcc.scp", \@mfccs);

my $cmd = qq(julius -h hmms/hmmmodel -filelist "$tempdir/mfcc.scp" -nlr "$lmf" -nrl "$lmb" -v "$wl" -hlist hmms/phones -walign -palign -input mfcfile -fallback1pass);
print STDERR "$cmd\n";
my $err = system($cmd);
die "julius failed with status $err" if $err;
