#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use File::Basename qw(basename fileparse);
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

for my $fn (@ARGV) {
    my $orig_fn = $fn;
    my $basefn = basename $fn;
    print STDERR "\n>>> $basefn \n";
    my ($stem) = fileparse($fn, qw(.mp3 .wav .flac));
    my $split_fn = "$splitdir/$stem.txt";

    my $split_fh;
    if (-e $split_fn) {
        say STDERR "found splits for $stem";
        open $split_fh, '<', $split_fn or die "Couldn't open $split_fn: $!";
    }
    else {
        say STDERR "generating splits for $stem";
        my $split_filecontents = join "", map "$_\n", map 100*$_, 1 .. `soxi -D "$fn"`/100;
        open $split_fh, '<', \$split_filecontents or die "Couldn't open generated splits for $stem: $!";
    }

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

        my $curr = $_;
        my $should_redo = 0;

        if (($curr - $prev) > 120) {
            $curr = $prev + 120;
            $should_redo = 1;
        }

        $chunk_fn = sprintf $output_template, $chunkdir, $stem, $prev, $curr, $output_format, $i;

        print STDERR "($i) $basefn => $chunk_fn $prev .. $curr\n";
        system qq{sox "$fn" --channels 1 "$chunk_fn" trim "$prev" "=$curr" remix -};

        $prev = $curr;
        $i++;

        redo if $should_redo;
    }
    my $flen = `soxi -D "$orig_fn"`;
    $chunk_fn = sprintf $output_template, $chunkdir, $stem, $prev, $flen, $output_format, $i;
    print STDERR "($i) $basefn => $chunk_fn $prev .. END\n";
    system qq{sox "$fn" --channels 1 "$chunk_fn" "trim" "$prev" remix -};
}
