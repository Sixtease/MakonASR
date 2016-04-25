#!/bin/bash

htkconf="$1"
shift
flacdir="$1"
shift
tempdir="$1"
shift
outdir="$1"
shift

if [ -e "$tempdir/SIGKILL" ]; then echo "konec"; exit 1; fi

ls "$flacdir" | while read infile; do
    stem=`basename $infile | sed -s /.flac//`
    echo "$stem" >&2;
    tempfile="$tempdir/$stem.wav"
    outfile="$outdir/$stem.mfcc"
    sox "$infile" "$tempfile" rate -v 16k && \
    HCopy -C "$htkconf" "$tempfile" "$outfile" && \
    rm $tempfile
done
