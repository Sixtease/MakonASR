#!/bin/bash

export BUILDING_LM=1

DEST_LM="${DEST_LM:-$ASR_ROOT/DATA/LM}"
DEST_WL="${DEST_WL:-$ASR_ROOT/DATA/wordlist}"
mwl="$wd/merged-wordlist"
c0="${general_corpus:-DATA/cnkcorpus}"
c1="$EV_corpus"
c2="$wd/sublm-corpus"
c3="$wd/humsublm-corpus"

get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$EV_workdir/humsublm-wordlist" "$EV_workdir/humsublm-corpus"
export LM_nonhumanic_only=1
get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$EV_workdir/sublm-wordlist" "$EV_workdir/sublm-corpus"
unset LM_nonhumanic_only
unset MAKONFM_SKIP_TEST_SUBS
corpus2wordlist.pl < "$c0" > "$wd/gen-wordlist"
corpus2wordlist.pl < "$c1" > "$wd/txt-wordlist"
merge-wordlists.pl 65000 "$wd/humsublm-wordlist" "$wd/sublm-wordlist" "$wd/txt-wordlist" > "$mwl"
merge-wordlists.pl infinity "$wd/humsublm-wordlist" "$wd/sublm-wordlist" "$wd/txt-wordlist" "$wd/gen-wordlist" > "$mwl-unlimited"

cat "$EV_corpus" > "$EV_workdir/merged-corpus"
cat "$EV_workdir/sublm-corpus" >> "$EV_workdir/merged-corpus"
for s in {1..2}; do cat "$EV_workdir/humsublm-corpus" >> "$EV_workdir/merged-corpus"; done  # TODO: exclude test data, optimize weight

ngram-count -order 3 -vocab "$EV_workdir/merged-wordlist" -text "$EV_workdir/merged-corpus"  -lm "$DEST_LM/tg.arpa"
reverse-corpus.pl < "$EV_workdir/merged-corpus" > "$EV_workdir/merged-corpusb"
ngram-count -order 3 -vocab "$EV_workdir/merged-wordlist" -text "$EV_workdir/merged-corpusb" -lm "$DEST_LM/tgb.arpa"
vyslov.pl < "$EV_workdir/merged-wordlist" > "$DEST_WL/wl-test-phonet"

ngram-count -order 3 -vocab "$mwl" -text "$c0"  -kndiscount1 -kn1 "$wd/kn0f1" -kndiscount2 -kn2 "$wd/kn0f2" -lm "$wd/lm0".arpa
ngram-count -order 3 -vocab "$mwl" -text "$c0"b -kndiscount1 -kn1 "$wd/kn0b1" -kndiscount2 -kn2 "$wd/kn0b2" -lm "$wd/lm0"b.arpa
ngram-count -order 3 -vocab "$mwl" -text "$c1"  -kndiscount1 -kn1 "$wd/kn1f1" -kndiscount2 -kn2 "$wd/kn1f2" -lm "$wd/lm1".arpa
ngram-count -order 3 -vocab "$mwl" -text "$c1"b -kndiscount1 -kn1 "$wd/kn1b1" -kndiscount2 -kn2 "$wd/kn1b2" -lm "$wd/lm1"b.arpa
ngram-count -order 3 -vocab "$mwl" -text "$c2"  -kndiscount1 -kn1 "$wd/kn2f1" -kndiscount2 -kn2 "$wd/kn2f2" -lm "$wd/lm2".arpa
ngram-count -order 3 -vocab "$mwl" -text "$c2"b -kndiscount1 -kn1 "$wd/kn2b1" -kndiscount2 -kn2 "$wd/kn2b2" -lm "$wd/lm2"b.arpa
ngram-count -order 3 -vocab "$mwl" -text "$c3"  -kndiscount1 -kn1 "$wd/kn3f1" -kndiscount2 -kn2 "$wd/kn3f2" -lm "$wd/lm3".arpa
ngram-count -order 3 -vocab "$mwl" -text "$c3"b -kndiscount1 -kn1 "$wd/kn3b1" -kndiscount2 -kn2 "$wd/kn3b2" -lm "$wd/lm3"b.arpa

#ngram -order 3 -lm "$wd/lm0".arpa  -lambda 0.2 -mix-lm "$wd/lm1".arpa  -mix-lm2 "$wd/lm2".arpa  -mix-lambda2 0.2 -mix-lm3 "$wd/lm3".arpa  -mix-lambda3 0.3 -write-lm "$DEST_LM/tg.arpa"
#ngram -order 3 -lm "$wd/lm0"b.arpa -lambda 0.2 -mix-lm "$wd/lm1"b.arpa -mix-lm2 "$wd/lm2"b.arpa -mix-lambda2 0.2 -mix-lm3 "$wd/lm3"b.arpa -mix-lambda3 0.3 -write-lm "$DEST_LM/tgb.arpa"

ngram -order 3 -lm "$wd/lm0".arpa  -lambda 0.0001 -mix-lm "$wd/lm1".arpa  -mix-lm2 "$wd/lm3".arpa  -mix-lambda2 0.7999 -write-lm "$DEST_LM/tg.arpa"
ngram -order 3 -lm "$wd/lm0"b.arpa -lambda 0.0001 -mix-lm "$wd/lm1"b.arpa -mix-lm2 "$wd/lm3"b.arpa -mix-lambda2 0.7999 -write-lm "$DEST_LM/tgb.arpa"

vyslov.pl < "$mwl" > "$DEST_WL/wl-test-phonet"

#rm "$wd"/{gen,txt,sublm,humsublm}-wordlist "$c2" "$c3" "$mwl" "$mwl-unlimited" "$c0"b "$c1"b "$c2"b "$c3"b "$wd"/kn{0..3}{f,b}{1,2} "$wd"/lm{0..3}{,b}.arpa
