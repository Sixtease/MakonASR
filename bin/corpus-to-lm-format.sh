#!/bin/bash

remove-punctuation.pl "$@" | corpus-to-lm-format.pl
