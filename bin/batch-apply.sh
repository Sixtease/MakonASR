#!/bin/bash

if [ -z "$MFCCDIR"  ]; then echo "MFCCDIR must be set" ; exit 1; fi
if [ -z "$SUBDIR"   ]; then echo "SUBDIR must be set"  ; exit 1; fi
if [ -z "$TEMPDIR"  ]; then echo "TEMPDIR must be set" ; exit 1; fi
if [ -z "$CHUNKDIR" ]; then echo "CHUNKDIR must be set"; exit 1; fi
RECOUTDIR="${RECOUTDIR:-$TEMPDIR}"

ls "$@" | while read f; do
    rm "$TEMPDIR"/*.* "$CHUNKDIR"/* 2> /dev/null
    stem=`basename "$f" | sed 's/\.sub\.js$//'`
    if [ -e "$SUBDIR/$stem.sub.js" ]; then
        echo "Sub exists: $stem ($SUBDIR/$stem.sub.js)"
        continue
    else
        touch "$SUBDIR/$stem.sub.js"
    fi
    split-by-subs.pl "$f" | split-mfcc.pl
#    if [ -e "$RECOUTDIR/recout-$stem" ]; then : ; else
    recognize-splitted.pl "$stem" "$CHUNKDIR" > "$RECOUTDIR/recout-$stem"
#    fi
    julout2subs.pl "$CHUNKDIR/splits" "$stem" < "$RECOUTDIR/recout-$stem" > "$SUBDIR/$stem.sub.js"
done
