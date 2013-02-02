#!/bin/bash

if echo "$*" | grep -q -- '--from-audio'; then
    export HCOPY_FROM_AUDIO=1
fi

get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | subs2train.pl "$MAKONFM_MFCC_DIR" "$EV_train_mfcc" "$MAKONFM_MP3_DIR" "$WAVDIR" all-utf8.mlf
iconv -f utf8 -t iso-8859-2 < all-utf8.mlf > all.mlf
echo 'splitting data to train and test...'
split-mlf.pl "$EV_train_transcription"=19 "$EV_test_transcription"=1 all.mlf
rm all.mlf all-utf8.mlf
echo 'generating training dictionary...'
mlf2wordlist.pl "$EV_train_transcription" | vyslov.pl > "$EV_wordlist_train_phonet"
