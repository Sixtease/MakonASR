#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Getopt::Long;
use File::Basename;
use lib "$ENV{EV_homedir}/lib", 'lib';
use HTKUtil;
use HTKout2subs;

my $splitdir = $ENV{SPLITDIR};
my $mfccdir  = $ENV{CHUNKDIR};
my $subdir   = $ENV{SUBDIR};
my $tempdir  = $ENV{TEMPDIR};

GetOptions(
    'splitdir=s' => \$splitdir,
    'mfccdir=s'  => \$mfccdir,
    'subdir=s'   => \$subdir,
    'tempdir=s'  => \$tempdir,
);

die 'EV_homedir must be set' if not $ENV{EV_homedir};

my ($audio_fn, $chunks_dir) = @ARGV;
my ($stem) = fileparse($audio_fn, qw(.mp3 .wav));

my @wavs = glob("$chunks_dir/*.wav");
my @mfccs = map {
    my ($stem) = fileparse($_, '.wav');
    "$mfccdir/$stem.mfcc"
} @wavs;
generate_scp("$tempdir/mfcc.scp", \@mfccs);
generate_scp("$tempdir/wav-mfcc.scp", \@wavs, \@mfccs);

my $err = system(qq(HCopy -A -D -T 1 -C "$ENV{EV_homedir}resources/htk-config-wav2mfcc" -S "$tempdir/wav-mfcc.scp"));
die "HCopy failed with status $err" if $err;

$err = system(qq(LANG=C HVite -A -D -T 1 -t 100 -m -C hmms/htk-config -H hmms/macros -H hmms/hmmdefs -S "$tempdir/mfcc.scp" -l  '*' -i "$tempdir/recout.mlf" -w DATA/LM/bg.lat -p "$ENV{EV_HVite_p}" -s "$ENV{EV_HVite_s}" DATA/wordlist/WORDLIST-test-unk-phonet hmms/phones));
die "HVite failed with status $err" if $err;

my $splits_fn = "$splitdir/$stem.txt";

{
    local (@ARGV, *STDIN, *STDOUT) = "$tempdir/recout.mlf";
    open STDOUT, '>', "$subdir/$stem.sub.js";
    HTKout2subs::convert($splits_fn, $stem);
}
