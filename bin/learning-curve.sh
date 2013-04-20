#!/bin/bash

for t in 12; do
    export discard_size="$t"
    echo "discarding $discard_size / 20" >> learning-curve.log
    export train_size=$((19-discard_size))
#    rm -R temp
    evadevi.pl
    ls -l temp/data/transcription/train/trans.mlf >> learning-curve.log
    mv hmms hmms-$t
done
