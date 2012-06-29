#!/bin/bash

fn="$1"
shift
outdir="$1"
shift
subdir="$1"
shift

bn=`basename "$fn"`
s n
split="$SPLITDIR/$bn.txt"
sub="$SUBDIR/$bn.sub"

if [ -e "$split" ]; then : ; else
    find-audio-splits.pl "$fn"
fi

split-audio.pl "$fn" "$SPLITDIR"
