#!/bin/bash

ls "$@" | while read f; do
    rm temp/*.* temp/chunks/*
    split-audio.pl --chunkdir temp/chunks "$f" || continue
    recognize-splitted.pl "$f" temp/chunks
done
