#!/bin/bash

. ../../config.sh

export general_corpus="$ASR_ROOT/DATA/cnkcorpus"

export EV_workdir=orig/temp
mkdir -p "$EV_workdir"

export DEST_LM=orig/LM
mkdir -p "$DEST_LM"

export DEST_WL=orig/wordlist
mkdir -p "$DEST_WL"

mklm.sh


export general_corpus="$ASR_ROOT/DATA/wmtcorpus"

export EV_workdir=altr/temp
mkdir -p "$EV_workdir"

export DEST_LM=altr/LM
mkdir -p "$DEST_LM"

export DEST_WL=altr/wordlist
mkdir -p "$DEST_WL"

mklm.sh
