#!/bin/bash

export BUILDING_LM=1

wd="$EV_workdir"
DEST_LM="${DEST_LM:-$ASR_ROOT/DATA/LM}"
DEST_WL="${DEST_WL:-$ASR_ROOT/DATA/wordlist}"
mwl="$wd/merged-wordlist"
c0="DATA/cnkcorpus"
c1="$EV_corpus"
c2="$wd/sublm-corpus"
c3="$wd/humsublm-corpus"

export MAKONFM_SKIP_TEST_SUBS=1
get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$wd/humsublm-wordlist" "$c3"
export LM_nonhumanic_only=1
get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$wd/sublm-wordlist" "$c2"
unset LM_nonhumanic_only
unset MAKONFM_SKIP_TEST_SUBS
corpus2wordlist.pl < "$c0" > "$wd/cnk-wordlist"
corpus2wordlist.pl < "$c1" > "$wd/txt-wordlist"
merge-wordlists.pl 65000 "$wd/humsublm-wordlist" "$wd/sublm-wordlist" "$wd/txt-wordlist" > "$mwl"
merge-wordlists.pl infinity "$wd/humsublm-wordlist" "$wd/sublm-wordlist" "$wd/txt-wordlist" "$wd/cnk-wordlist" > "$mwl-unlimited"

reverse-corpus.pl < "$c0" > "$c0"b
reverse-corpus.pl < "$c1" > "$c1"b
reverse-corpus.pl < "$c2" > "$c2"b
reverse-corpus.pl < "$c3" > "$c3"b

ngram-count -order 3 -vocab "$mwl-unlimited" -text "$c0"  -kn1 "$wd/kn0f1" -kn2 "$wd/kn0f2"
ngram-count -order 3 -vocab "$mwl-unlimited" -text "$c0"b -kn1 "$wd/kn0b1" -kn2 "$wd/kn0b2"
ngram-count -order 3 -vocab "$mwl-unlimited" -text "$c1"  -kn1 "$wd/kn1f1" -kn2 "$wd/kn1f2"
ngram-count -order 3 -vocab "$mwl-unlimited" -text "$c1"b -kn1 "$wd/kn1b1" -kn2 "$wd/kn1b2"
ngram-count -order 3 -vocab "$mwl-unlimited" -text "$c2"  -kn1 "$wd/kn2f1" -kn2 "$wd/kn2f2"
ngram-count -order 3 -vocab "$mwl-unlimited" -text "$c2"b -kn1 "$wd/kn2b1" -kn2 "$wd/kn2b2"
ngram-count -order 3 -vocab "$mwl-unlimited" -text "$c3"  -kn1 "$wd/kn3f1" -kn2 "$wd/kn3f2"
ngram-count -order 3 -vocab "$mwl-unlimited" -text "$c3"b -kn1 "$wd/kn3b1" -kn2 "$wd/kn3b2"

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

#rm "$wd"/{cnk,txt,sublm,humsublm}-wordlist "$c2" "$c3" "$mwl" "$mwl-unlimited" "$c0"b "$c1"b "$c2"b "$c3"b "$wd"/kn{0..3}{f,b}{1,2} "$wd"/lm{0..3}{,b}.arpa
