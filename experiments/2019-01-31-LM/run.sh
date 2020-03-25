#!/bin/bash

. ../../config.sh

export general_corpus="$ASR_ROOT/DATA/cnkcorpus"

export EV_workdir=orig/temp
mkdir -p "$EV_workdir"

export DEST_LM_DIR=orig/LM
mkdir -p "$DEST_LM_DIR"

export DEST_WL_DIR=orig/wordlist
mkdir -p "$DEST_WL_DIR"

mklm.sh


export general_corpus="$ASR_ROOT/DATA/wmtcorpus"

export EV_workdir=altr/temp
mkdir -p "$EV_workdir"

export DEST_LM_DIR=altr/LM
mkdir -p "$DEST_LM_DIR"

export DEST_WL_DIR=altr/wordlist
mkdir -p "$DEST_WL_DIR"

mklm.sh
