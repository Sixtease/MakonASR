#!/bin/bash

export BUILDING_LM=1

DEST_LM="${DEST_LM:-DATA/LM}"
DEST_WL="${DEST_WL:-DATA/wordlist}"

export LM_include_nonhumanic_subs=1
get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$EV_workdir/sublm-wordlist" "$EV_workdir/sublm-corpus"
unset LM_include_nonhumanic_subs
get_humanic_subs.pl "$MAKONFM_SUB_DIR"/*.sub.js | sublm-mkdict-mkcorpus.pl "$EV_workdir/humsublm-wordlist" "$EV_workdir/humsublm-corpus"
corpus2wordlist.pl < "$EV_corpus" > "$EV_workdir/txt-wordlist"
merge-wordlists.pl 65000 "$EV_workdir/sublm-wordlist" "$EV_workdir/txt-wordlist" > "$EV_workdir/merged-wordlist"

cat "$EV_corpus" > "$EV_workdir/merged-corpus"
cat "$EV_workdir/sublm-corpus" >> "$EV_workdir/merged-corpus"
for s in {1..20}; do cat "$EV_workdir/humsublm-corpus" >> "$EV_workdir/merged-corpus"; done

ngram-count -order 3 -vocab "$EV_workdir/merged-wordlist" -text "$EV_workdir/merged-corpus"  -lm "$DEST_LM/tg.arpa"
reverse-corpus.pl < "$EV_workdir/merged-corpus" > "$EV_workdir/merged-corpusb"
ngram-count -order 3 -vocab "$EV_workdir/merged-wordlist" -text "$EV_workdir/merged-corpusb" -lm "$DEST_LM/tgb.arpa"
vyslov.pl < "$EV_workdir/merged-wordlist" > "$DEST_WL/wl-test-phonet"

#rm "$EV_workdir/sublm-wordlist" "$EV_workdir/sublm-corpus" "$EV_workdir/txt-wordlist" "$EV_workdir/merged-wordlist" "$EV_workdir/merged-corpus"
