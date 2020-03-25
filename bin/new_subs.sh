#!/bin/bash

if echo "$*" | grep -q -- '--from-audio'; then
    export HCOPY_FROM_AUDIO=1
fi

: ${MAKONFM_AUDIODIR:="$MAKONFM_FLAC_DIR"}

get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | subs2train.pl "$MAKONFM_MFCC_DIR" "$EV_train_mfcc" "$MAKONFM_AUDIODIR" "$WAVDIR" train-utf8.mlf test-utf8.mlf
iconv -f utf8 -t iso-8859-2 < train-utf8.mlf > "$EV_train_transcription"
iconv -f utf8 -t iso-8859-2 < test-utf8.mlf  > "$EV_test_transcription"
rm train-utf8.mlf test-utf8.mlf
echo 'generating training dictionary...'
mlf2wordlist.pl "$EV_train_transcription" | vyslov.pl > "$EV_wordlist_train_phonet"
