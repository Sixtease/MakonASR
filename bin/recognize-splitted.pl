#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Getopt::Long;
use File::Basename;
use HTKUtil;
use HTKout2subs;

my $splitdir = $ENV{SPLITDIR};
my $mfccdir  = $ENV{CHUNKDIR};
my $subdir   = $ENV{SUBDIR};

GetOptions(
    'splitdir=s' => \$splitdir,
    'mfccdir=s'  => \$mfccdir,
    'subdir=s'   => \$subdir,
);

die 'EV_homedir must be set' if not $ENV{EV_homedir};

my ($audio_fn, $chunks_dir) = @ARGV;
my ($stem) = fileparse($audio_fn, qw(.mp3 .wav));

my @wavs = glob("$chunks_dir/*.wav");
my @mfccs = map {
    my ($stem) = fileparse($_, '.wav');
    "$mfccdir/$stem.mfcc"
} @wavs;
generate_scp('temp/mfcc.scp', \@mfccs);
generate_scp('temp/wav-mfcc.scp', \@wavs, \@mfccs);

my $err = system(qq(HCopy -A -D -T 1 -C "$ENV{EV_homedir}resources/htk-config-wav2mfcc" -S temp/wav-mfcc.scp));
die "HCopy failed with status $err" if $err;

$err = system(qq(LANG=C HVite -A -D -T 1 -t 100 -m -C hmms/htk-config -H hmms/macros -H hmms/hmmdefs -S temp/mfcc.scp -l  '*' -i temp/recout.mlf -w DATA/LM/bg.lat -p "$ENV{EV_HVite_p}" -s "$ENV{EV_HVite_s}" DATA/wordlist/WORDLIST-test-unk-phonet hmms/phones));
die "HVite failed with status $err" if $err;

my $splits_fn = "$splitdir/$stem.txt";

{
    local @ARGV, *STDIN, *STDOUT = 'temp/recout.mlf';
    open STDOUT, '>', "$subdir/$stem.sub.js";
    HTKout2subs::convert($splits_fn, $stem);
}
