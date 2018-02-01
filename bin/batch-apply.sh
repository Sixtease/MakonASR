#!/bin/bash

if [ -z "$MFCCDIR" ]; then export MFCCDIR="$MAKONFM_MFCC_DIR"; fi
if [ -z "$MAKONFM_SUB_DIR"  ]; then echo "MAKONFM_SUB_DIR must be set" ; exit 1; fi
if [ -z "$WORKDIR" ]; then echo "WORKDIR must be set"; exit 1; fi

RECOUTDIR="${RECOUTDIR:-$WORKDIR/recout}"

mkdir -p "$RECOUTDIR"

for f in "$@"; do
    if [ -e '/tmp/SIGKILL' ]; then echo 'interrupt'; exit 1; fi
    stem=`basename "$f" | sed 's/\.sub\.js$//' | sed 's/\.mfcc$//'`
    export TEMPDIR="$WORKDIR/$stem"
    export CHUNKDIR="$TEMPDIR/chunks"
    if [ -e "$f" ]; then :; else echo "no mfcc for $stem; skipping"; continue; fi
    if mkdir "$TEMPDIR" 2>/dev/null; then echo "taking $stem" ; else echo "skipping $stem"; continue; fi
    mkdir "$CHUNKDIR"

    if [ -n "$MAKONFM_NAIVE_SPLIT" ]; then
        naively-split-mfcc.pl "$f" | split-mfcc.pl
    else
        split-by-subs.pl "$f" | split-mfcc.pl
    fi

#    if [ -e "$RECOUTDIR/$stem" ]; then : ; else
    recognize-splitted.pl "$stem" "$CHUNKDIR" > "$RECOUTDIR/$stem"
#    fi
    if [ -z "$RECOUT_ONLY" ]; then
        julout2subs.pl "$CHUNKDIR/splits" "$stem" < "$RECOUTDIR/$stem" > "$MAKONFM_SUB_DIR/$stem.sub.js"
    fi
    rm -R "$CHUNKDIR"/*.mfcc
done
