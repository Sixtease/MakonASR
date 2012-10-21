#!/bin/bash

export PATH="bin:/home/sixtease/git/Evadevi/bin:/home/sixtease/programs/lmhtk/bin:/home/sixtease/share/install/srilm/bin:/home/sixtease/share/install/srilm/bin/i686:$PATH"
export EV_homedir=~/git/Evadevi/
export EV_workdir=temp/
export EV_outdir=hmms/

export EV_train_mfcc="DATA/mfcc"
export EV_wordlist_train_phonet="DATA/wordlist/wl-train-phonet"
export EV_train_transcription="DATA/transcription/train.mlf"
export EV_LM="DATA/LM/bg.lat"
export EV_wordlist_test_phonet="DATA/wordlist/wl-test-phonet"
export EV_tree_hed="DATA/tree.hed"
export EV_triphone_tree="DATA/triphone-tree"

export EV_test_transcription="DATA/transcription/test.mlf"
export EV_test_mfcc="$EV_train_mfcc"

export EV_use_triphones='1'
export EV_min_mixtures=8

export EV_HERest_p=4

export EV_HVite_p='8.0'
export EV_HVite_s='6.0'
export EV_HVite_t='150.0'

export EV_iter_init=2
export EV_iter_sp=2
export EV_iter_align=2
export EV_iter_var=2
export EV_iter_triphones=3
export EV_iter_mixtures=4

export EV_thread_cnt=2
export EV_heldout_ratio=19

export EV_corpus="DATA/corpus"
export EV_word_blacklist="DATA/wordlist/blacklist"

export SPLITDIR='/home/sixtease/Documents/Kama/meta/splits'
export SUBDIR='/home/sixtease/dokumenty/skola/phd/webapp/MakonFM/root/static/subs'
export CHUNKDIR='temp/chunks'
export TEMPDIR='temp'
export WAVDIR='DATA/wav'

export SUB_EXTRACTION_LOG="$TEMPDIR/sub_extraction_log"

export MAKONFM_SUB_DIR='/home/sixtease/dokumenty/skola/phd/webapp/MakonFM/root/static/subs'
export MAKONFM_MFCC_DIR='/home/sixtease/Music/Makon/mfcc'
export MAKONFM_MP3_DIR='/home/sixtease/Music/Makon/all/mp3'
