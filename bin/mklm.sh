#!/bin/bash

export BUILDING_LM=1

DEST_LM="${DEST_LM:-$ASR_ROOT/DATA/LM}"
DEST_WL="${DEST_WL:-$ASR_ROOT/DATA/wordlist}"

export LM_nonhumanic_only=1
get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$EV_workdir/sublm-wordlist" "$EV_workdir/sublm-corpus"
unset LM_nonhumanic_only
mlf2wordlist.pl "$EV_train_transcription" > "$EV_workdir/humsublm-wordlist"
mlf2corpus.pl   "$EV_train_transcription" > "$EV_workdir/humsublm-corpus"
corpus2wordlist.pl < "$EV_corpus" > "$EV_workdir/txt-wordlist"
merge-wordlists.pl 65000 "$EV_workdir/humsublm-wordlist" "$EV_workdir/sublm-wordlist" "$EV_workdir/txt-wordlist" > "$EV_workdir/merged-wordlist"

cat "$EV_corpus" > "$EV_workdir/merged-corpus"
cat "$EV_workdir/sublm-corpus" >> "$EV_workdir/merged-corpus"
for s in {1..2}; do cat "$EV_workdir/humsublm-corpus" >> "$EV_workdir/merged-corpus"; done  # TODO: exclude test data, optimize weight

ngram-count -order 3 -vocab "$EV_workdir/merged-wordlist" -text "$EV_workdir/merged-corpus"  -lm "$DEST_LM/tg.arpa"
reverse-corpus.pl < "$EV_workdir/merged-corpus" > "$EV_workdir/merged-corpusb"
ngram-count -order 3 -vocab "$EV_workdir/merged-wordlist" -text "$EV_workdir/merged-corpusb" -lm "$DEST_LM/tgb.arpa"
vyslov.pl < "$EV_workdir/merged-wordlist" > "$DEST_WL/wl-test-phonet"

#rm "$EV_workdir/sublm-wordlist" "$EV_workdir/sublm-corpus" "$EV_workdir/txt-wordlist" "$EV_workdir/merged-wordlist" "$EV_workdir/merged-corpus"
