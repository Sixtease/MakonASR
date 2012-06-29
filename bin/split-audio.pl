#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use File::Basename;
use Getopt::Long;
use File::Temp qw(:seekable);

my $splitdir = $ENV{SPLITDIR};
my $subdir   = $ENV{SUBDIR};
my $chunkdir = $ENV{CHUNKDIR};

GetOptions(
    'splitdir=s' => \$splitdir,
    'subdir=s'   => \$subdir,
    'chunkdir=s' => \$chunkdir,
);

my ($fn) = @ARGV;
my ($stem) = fileparse($fn, qw(.mp3 .wav));
my $split_fn = "$splitdir/$stem.txt";
my $sub_fn = "$subdir/$stem.sub.js";

unless (-e $split_fn) {
    system(qq(find-audio-splits.pl --outdir "$splitdir" "$fn"));
}

open my $split_fh, '<', $split_fn or die "Couldn't open $split_fn: $!";

if ($fn =~ /\.mp3$/) {
    my $tmp = File::Temp->new(SUFFIX => '.wav');
    open my $lame_fh, '-|', qq{lame --decode "$fn" -} or die "couldn't start lame: $!";
    {
        local $/;
        print {$tmp} <$lame_fh>;
    }
    $tmp->seek(0, SEEK_SET);
    $fn = $tmp;
}

my $prev = 0;
my $i = '000';
my $chunk_fn;

while (<$split_fh>) {
    chomp;
    $chunk_fn = "$chunkdir/chunk$i.wav";
    print STDERR "($i) $fn => $chunk_fn $prev .. $_\n";
    system qq{sox "$fn" "$chunk_fn" "trim" "$prev" "=$_"};
} continue {
    $prev = $_;
    $i++;
}
$chunk_fn = "$chunkdir/chunk$i.wav";
print STDERR "($i) $fn => $chunk_fn $prev .. END\n";
system qq{sox "$fn" "$chunk_fn" "trim" "$prev"};
