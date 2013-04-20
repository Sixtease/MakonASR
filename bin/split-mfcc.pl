#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use File::Basename;
use Getopt::Long;
use File::Temp qw(:seekable);

my $mfccdir   =  $ENV{MFCCDIR};
my $subdir    =  $ENV{SUBDIR};
my $chunkdir  =  $ENV{CHUNKDIR};
my $conf_fn   = "$ENV{EV_homedir}resources/htk-config-mfcc2mfcc-full";

GetOptions(
    'subdir=s'   => \$subdir,
    'chunkdir=s' => \$chunkdir,
    'mfccdir=s'  => \$mfccdir,
);

my $sub_fn;
my $chunk_fn;
open my $splits_fh, '>', "$chunkdir/splits" or die "Couldn't open split file '$chunkdir/splits' for writing: $!";

while (<>) {
    print STDERR;
    print {$splits_fh} $_;
    my ($chunk_id, $stem, $start, $end) = m/^(\S+)\s+(\S+)\s+([\d.]+)\s+\.\.\s+([\d.]+)/ or next;
    my $mfcc_fn = "$mfccdir/$stem.mfcc";
    $chunk_fn = "$chunkdir/$stem-$chunk_id.mfcc";
    system qq(HCopy -C "$conf_fn" -s ${start}e7 -e ${end}e7 "$mfcc_fn" "$chunk_fn");
}

close $splits_fh;
