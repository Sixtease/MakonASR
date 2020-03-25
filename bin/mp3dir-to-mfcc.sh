#!/bin/bash

#. ~/funkce.sh

usage() {
    echo "$0 -i input_directory [-o output_directory] -C htk-config-wav2mfcc -t temp_directory *.mp3"
    exit 1
}

outdir='.'
tempdir='/tmp'
C=${EV_homedir}resources/htk-config-wav2mfcc

while getopts 'i:o:C:t:' OPTION; do
    case "$OPTION" in
    i)
        indir="$OPTARG"
        ;;
    o)
        outdir="$OPTARG"
        ;;
    C)
        C="$OPTARG"
        ;;
    t)
        tempdir="$OPTARG"
        ;;
    ?)
        usage
        ;;
    esac
done

echo "indir: $indir, outdir: $outdir, tempdir: $tempdir, htkconf: $C"

if [ -d "$indir" ]; then : ; else
    usage
    exit 1
fi

ls "$indir" | while read s; do
    if [ -e "$tempdir/SIGKILL" ]; then echo konec; exit 1; fi
    stem="`basename $s | sed s/.mp3//`"
    infile="$indir/$s"
    echo `date '+%T'` $stem >&2
    tmp="$tempdir/$stem.wav"
    outfile="$outdir/$stem.mfcc"
    lame --decode "$infile" - | sox - "$tmp" remix - rate -v 16k && \
    HCopy -C "$C" "$tmp" "$outfile" && \
    rm "$tmp"
done
