#!/bin/bash

export BUILDING_LM=1

DEST_LM="${DEST_LM:-$ASR_ROOT/DATA/LM}"
DEST_WL="${DEST_WL:-$ASR_ROOT/DATA/wordlist}"
mwl="$EV_workdir/merged-wordlist"
mc="$EV_workdir/merged-corpus"

# TODO: exclude test data
export MAKONFM_SKIP_TEST_SUBS=1
get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$EV_workdir/humsublm-wordlist" "$EV_workdir/humsublm-corpus"
export LM_nonhumanic_only=1
get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$EV_workdir/sublm-wordlist" "$EV_workdir/sublm-corpus"
unset LM_nonhumanic_only
unset MAKONFM_SKIP_TEST_SUBS
corpus2wordlist.pl < "$EV_corpus" > "$EV_workdir/txt-wordlist"
merge-wordlists.pl 65000 "$EV_workdir/humsublm-wordlist" "$EV_workdir/sublm-wordlist" "$EV_workdir/txt-wordlist" > "$mwl"
merge-wordlists.pl infinity "$EV_workdir/humsublm-wordlist" "$EV_workdir/sublm-wordlist" "$EV_workdir/txt-wordlist" > "$mwl-unlimited"

cat "$EV_corpus" > "$mc"
cat "$EV_workdir/sublm-corpus" >> "$mc"
for s in {1..2}; do cat "$EV_workdir/humsublm-corpus" >> "$mc"; done  # TODO: exclude test data, optimize weight

reverse-corpus.pl < "$mc" > "$mc"b

ngram-count -order 3 -vocab "$mwl-unlimited" -text "$mc"  -kn1 "$EV_workdir/knf1" -kn2 "$EV_workdir/knf2"
ngram-count -order 3 -vocab "$mwl-unlimited" -text "$mc"b -kn1 "$EV_workdir/knb1" -kn2 "$EV_workdir/knb2"

ngram-count -order 3 -vocab "$mwl" -text "$mc"  -kndiscount1 -kn1 "$EV_workdir/knf1" -kndiscount2 -kn2 "$EV_workdir/knf2" -lm "$DEST_LM/tg.arpa"
ngram-count -order 3 -vocab "$mwl" -text "$mc"b -kndiscount1 -kn1 "$EV_workdir/knb1" -kndiscount2 -kn2 "$EV_workdir/knb2" -lm "$DEST_LM/tgb.arpa"

vyslov.pl < "$mwl" > "$DEST_WL/wl-test-phonet"

echo rm "$EV_workdir/sublm-wordlist" "$EV_workdir/sublm-corpus" "$EV_workdir/txt-wordlist" "$mwl" "$mc" "$EV_workdir/knf1" "$EV_workdir/knf2"
