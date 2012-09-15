#!/bin/bash

ls "$@" | while read f; do
    rm "$TEMPDIR"/*.* "$CHUNKDIR"/* 2> /dev/null
    split-audio.pl --chunkdir="$CHUNKDIR" "$f" || continue
    recognize-splitted.pl --mfccdir="$CHUNKDIR" "$f" "$CHUNKDIR"
done
