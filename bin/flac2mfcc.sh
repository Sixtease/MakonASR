#!/bin/bash

#. ~/funkce.sh

usage() {
    echo "$0 -i input_directory [-o output_directory] -C htk-config-wav2mfcc -t temp_directory *.flac"
    exit 1
}

outdir='.'
tempdir='/tmp'
C=~/git/Evadevi/resources/htk-config-wav2mfcc

while getopts 'i:o:C:t:' OPTION; do
    case "$OPTION" in
    i)
        indir="$OPTARG" ;;
    o)
        outdir="$OPTARG" ;;
    C)
        C="$OPTARG" ;;
    t)
        tempdir="$OPTARG" ;;
    ?)
        usage ;;
    esac
done
shift $((OPTIND-1))

wildcard="$1"; shift

echo "indir: $indir, outdir: $outdir, tempdir: $tempdir, htkconf: $C, wildcard: $wildcard"

if [ -d "$indir" ]; then : ; else
    usage
    exit 1
fi

ls "$indir/"$wildcard | while read s; do
    if [ -e "$tempdir/SIGKILL" ]; then echo konec; exit 1; fi
    stem="`basename $s | sed s/.flac//`"
    infile="$s"
    echo `date '+%T'` $stem >&2
    tmp="$tempdir/$stem.wav"
    outfile="$outdir/$stem.mfcc"
    if [ -e "$outfile" ]; then echo file exists $outfile; continue; fi
    sox "$infile" "$tmp" remix - rate -v 16k && \
    HCopy -C "$C" "$tmp" "$outfile" && \
    rm "$tmp"
done
