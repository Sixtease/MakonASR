#!/bin/bash

if [ -z "$MFCCDIR" ]; then echo "MFCCDIR must be set"; exit 1; fi
if [ -z "$SUBDIR"  ]; then echo "SUBDIR must be set" ; exit 1; fi
if [ -z "$WORKDIR" ]; then echo "WORKDIR must be set"; exit 1; fi

RECOUTDIR="${RECOUTDIR:-$WORKDIR}"

ls "$@" | while read f; do
    if [ -e '/tmp/SIGKILL' ]; then echo 'interrupt'; exit 1; fi
    stem=`basename "$f" | sed 's/\.sub\.js$//'`
    export TEMPDIR="$WORKDIR/$stem"
    export CHUNKDIR="$TEMPDIR/chunks"
    if mkdir "$TEMPDIR" 2>/dev/null; then echo "taking $stem" ; else echo "skipping $stem"; continue; fi
    mkdir "$CHUNKDIR"
    split-by-subs.pl "$f" | split-mfcc.pl
#    if [ -e "$RECOUTDIR/$stem" ]; then : ; else
    recognize-splitted.pl "$stem" "$CHUNKDIR" > "$RECOUTDIR/$stem"
#    fi
    julout2subs.pl "$CHUNKDIR/splits" "$stem" < "$RECOUTDIR/$stem" > "$SUBDIR/$stem.sub.js"
    rm -R "$CHUNKDIR"/*.mfcc
done
