#!/bin/bash

recoutdir=$1
shift

for s in "$recoutdir"/recout/*; do
    stem=`basename "$s"`
    echo $stem
    julout2subs.pl "$recoutdir"/temp/"$stem"/chunks/splits "$stem" < "$recoutdir"/recout/"$stem" > "$recoutdir"/subs/"$stem".sub.js
done
