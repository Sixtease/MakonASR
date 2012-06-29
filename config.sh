#!/bin/bash

export PATH="/home/sixtease/git/Evadevi/bin:/home/sixtease/programs/lmhtk/bin:$PATH"
export EV_homedir=~/git/Evadevi/
export EV_workdir=temp/
export EV_outdir=hmms/

export EV_train_mfcc="DATA/mfcc/train"
export EV_wordlist_train_phonet="DATA/wordlist/wl-train-phonet"
export EV_train_transcription="DATA/transcription/train.mlf"
export EV_LM="DATA/LM/bg.lat"
export EV_wordlist_test_phonet="DATA/wordlist/wl-test-phonet"

export EV_test_transcription="DATA/transcription/test.mlf"
export EV_test_mfcc="DATA/mfcc/test"

export EV_use_triphones=''
export EV_min_mixtures=8

export EV_HVite_p='8.0'
export EV_HVite_s='6.0'
export EV_HVite_t='150.0'

export EV_iter1=2
export EV_iter2=2
export EV_iter3=2

# export EV_corpus="${EV_homedir}given/data/corpus"

export SPLITDIR='/home/sixtease/Documents/Kama/meta/splits'
export SUBDIR='/home/sixtease/dokumenty/skola/phd/webapp/MakonFM/root/static/subs'
export CHUNKDIR='temp/chunks'
