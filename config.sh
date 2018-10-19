#!/bin/bash

export ASR_ROOT=~/skola/phd/asr

export PATH="$ASR_ROOT/bin:/home/sixtease/git/Evadevi/bin:/home/sixtease/programs/lmhtk/bin:/home/sixtease/share/install/srilm/srilm-1.7.2/bin/i686-m64:/home/sixtease/share/install/srilm/srilm-1.7.2/bin:$PATH"

export EV_homedir=~/git/Evadevi/
export EV_workdir="$ASR_ROOT/temp/"
export EV_outdir="$ASR_ROOT/hmms/"

export PERL5LIB="${EV_homedir}lib:$ASR_ROOT/lib:$PERL5LIB"

export EV_encoding='iso-8859-2'

export EV_train_mfcc="$ASR_ROOT/DATA/mfcc"
export EV_wordlist_train_phonet="$ASR_ROOT/DATA/wordlist/wl-train-phonet"
export EV_train_transcription="$ASR_ROOT/DATA/transcription/train.mlf"
export EV_LM="$ASR_ROOT/DATA/LM/bg.lat"
export EV_LMf="$ASR_ROOT/DATA/LM/tg.arpa"
export EV_LMb="$ASR_ROOT/DATA/LM/tgb.arpa"
export EV_wordlist_test_phonet="$ASR_ROOT/DATA/wordlist/wl-test-phonet"
export EV_tree_hed="$ASR_ROOT/DATA/tree.hed"
export EV_triphone_questions="$ASR_ROOT/DATA/triphone-questions"

export EV_test_transcription="$ASR_ROOT/DATA/transcription/test.mlf"
export EV_test_mfcc="$EV_train_mfcc"

export EV_use_triphones='1'
export EV_min_mixtures=15

export EV_HERest_p=8

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
export EV_heldout_ratio=40

export EV_corpus="$ASR_ROOT/DATA/corpus"
export EV_word_blacklist="$ASR_ROOT/DATA/wordlist/blacklist"

export EV_evaluate_steps=1

export SPLITDIR='/home/sixtease/Documents/Kama/meta/splits'
#export SUBDIR='/home/sixtease/dokumenty/skola/phd/webapp/MakonFM/root/static/subs'
export CHUNKDIR="$ASR_ROOT/temp/chunks"
export TEMPDIR="$ASR_ROOT/temp"
export WAVDIR="$ASR_ROOT/DATA/wav"

export SUB_EXTRACTION_LOG="$TEMPDIR/sub_extraction_log"

export MAKONFM_SUB_DIR='/home/sixtease/dokumenty/skola/phd/webapp/MakonFM/root/static/subs'
export MAKONFM_MFCC_DIR='/home/sixtease/kroupy/Music/Makon/mfcc'
export MAKONFM_MP3_DIR='/home/sixtease/kroupy/Music/Makon/all/mp3'

export MAKONFM_TEST_TRACKS="76-05B-Kaly-10:82-01A:kotouc-S01-c:86-05A-Brno-9.2.1986-3:90-45A"
export MAKONFM_TEST_START_POS=60    # take testing data from 1 minute into the track
export MAKONFM_TEST_END_POS=660     # up to minute 11 (10 minutes total per track)

export MAKONFM_PHONE_MAP="$ASR_ROOT/DATA/phone-map" # phone substitutions to avoid infrequent phones

. "${EV_homedir}config.sh"
if [ -e config_local.sh ]; then . config_local.sh; fi
