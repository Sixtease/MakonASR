#!/bin/bash

export BUILDING_LM=1
export MAKONFM_SKIP_TEST_SUBS=1

DEST_LM_DIR="${DEST_LM_DIR:-$ASR_ROOT/DATA/LM}"
DEST_WL_DIR="${DEST_WL_DIR:-$ASR_ROOT/DATA/wordlist}"
wd="$EV_workdir"
c0="${general_corpus:-DATA/cnkcorpus}"
c1="$EV_corpus"
c2="$wd/sublm-corpus"
c3="$wd/humsublm-corpus"
ct="$wd/tuning-corpus"


get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$wd/humsublm-wordlist" "$wd/humsub-total-corpus"
evenly-move-lines.pl 500 "$ct" "$c3" "$wd/humsub-total-corpus"

export LM_nonhumanic_only=1
get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$wd/sublm-wordlist" "$c2"
unset LM_nonhumanic_only
unset MAKONFM_SKIP_TEST_SUBS

corpus2wordlist.pl < "$c0" > "$wd/gen-wordlist"
corpus2wordlist.pl < "$c1" > "$wd/txt-wordlist"
merge-wordlists.pl 65000 "$wd/humsublm-wordlist" "$wd/sublm-wordlist" "$wd/txt-wordlist" > "$mwl"
#merge-wordlists.pl infinity "$wd/humsublm-wordlist" "$wd/sublm-wordlist" "$wd/txt-wordlist" "$wd/gen-wordlist" > "$mwl-unlimited"

if [ ! -e "$c0"b ]; then reverse-corpus.pl < "$c0" > "$c0"b; fi
if [ ! -e "$c1"b ]; then reverse-corpus.pl < "$c1" > "$c1"b; fi
if [ ! -e "$c2"b ]; then reverse-corpus.pl < "$c2" > "$c2"b; fi
if [ ! -e "$c3"b ]; then reverse-corpus.pl < "$c3" > "$c3"b; fi
if [ ! -e "$ct"b ]; then reverse-corpus.pl < "$ct" > "$ct"b; fi

lmplz --order 3 --intermediate --memory 90% --temp_prefix "$wd" < "$c0" > "$wd/lm0".arpa
lmplz --order 3 --intermediate --memory 90% --temp_prefix "$wd" < "$c1" > "$wd/lm1".arpa
lmplz --order 3 --intermediate --memory 90% --temp_prefix "$wd" < "$c2" > "$wd/lm2".arpa
lmplz --order 3 --intermediate --memory 90% --temp_prefix "$wd" < "$c3" > "$wd/lm3".arpa
#vyslov.pl < "$wd/merged-wordlist" > "$DEST_WL_DIR/wl-test-phonet"

lmplz --order 3 --intermediate --memory 90% --temp_prefix "$wd" < "$c0"b > "$wd/lm0"b.arpa
lmplz --order 3 --intermediate --memory 90% --temp_prefix "$wd" < "$c1"b > "$wd/lm1"b.arpa
lmplz --order 3 --intermediate --memory 90% --temp_prefix "$wd" < "$c2"b > "$wd/lm2"b.arpa
lmplz --order 3 --intermediate --memory 90% --temp_prefix "$wd" < "$c3"b > "$wd/lm3"b.arpa

#ngram -order 3 -lm "$wd/lm0".arpa  -lambda 0.2 -mix-lm "$wd/lm1".arpa  -mix-lm2 "$wd/lm2".arpa  -mix-lambda2 0.2 -mix-lm3 "$wd/lm3".arpa  -mix-lambda3 0.3 -write-lm "$DEST_LM_DIR/tg.arpa"
#ngram -order 3 -lm "$wd/lm0"b.arpa -lambda 0.2 -mix-lm "$wd/lm1"b.arpa -mix-lm2 "$wd/lm2"b.arpa -mix-lambda2 0.2 -mix-lm3 "$wd/lm3"b.arpa -mix-lambda3 0.3 -write-lm "$DEST_LM_DIR/tgb.arpa"

interpolate -m "$c0"  "$c1"  "$c2"  "$c3"  -t "$ct"  --temp_prefix "$wd" --memory 90% > "$DEST_LM_DIR/tg.arpa"
interpolate -m "$c0"b "$c1"b "$c2"b "$c3"b -t "$ct"b --temp_prefix "$wd" --memory 90% > "$DEST_LM_DIR/tgb.arpa"

#vyslov.pl < "$mwl" > "$DEST_WL_DIR/wl-test-phonet"

#rm "$wd"/{gen,txt,sublm,humsublm}-wordlist "$c2" "$c3" "$mwl" "$mwl-unlimited" "$c0"b "$c1"b "$c2"b "$c3"b "$wd"/kn{0..3}{f,b}{1,2} "$wd"/lm{0..3}{,b}.arpa
