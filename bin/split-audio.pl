#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use File::Basename;
use Getopt::Long;
use File::Temp qw(:seekable);

my $output_format = 'wav';
my $splitdir = $ENV{SPLITDIR};
my $chunkdir = $ENV{CHUNKDIR};
my $output_file_naming = $ENV{OUTPUT_FILE_NAMING};

GetOptions(
    'splitdir=s' => \$splitdir,
    'chunkdir=s' => \$chunkdir,
    'output-format=s' => \$output_format,
    'output-file-naming=s' => \$output_file_naming,
);

my $output_template = "%1\$s/chunk%6\$d.%5\$s";
if ($output_file_naming eq 'chunks') {
    # OK
}
elsif ($output_file_naming eq 'intervals') {
    $output_template = "%s/%s--from-%07.2f--to-%07.2f.%s";
}
elsif (defined $output_file_naming) {
    die "Unexpected file naming: $output_file_naming";
}

my ($fn) = @ARGV;
my ($stem) = fileparse($fn, qw(.mp3 .wav .flac));
my $split_fn = "$splitdir/$stem.txt";

if (not -e $split_fn) {
    die "no split file $split_fn";
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

    $chunk_fn = sprintf $output_template, $chunkdir, $stem, $prev, $_, $output_format, $i;

    print STDERR "($i) $fn => $chunk_fn $prev .. $_\n";
    system qq{sox "$fn" --channels 1 "$chunk_fn" trim "$prev" "=$_" remix -};
} continue {
    $prev = $_;
    $i++;
}
my $flen = `soxi -D "$fn"`;
$chunk_fn = sprintf $output_template, $chunkdir, $stem, $prev, $flen, $output_format, $i;
print STDERR "($i) $fn => $chunk_fn $prev .. END\n";
system qq{sox "$fn" --channels 1 "$chunk_fn" "trim" "$prev" remix -};
