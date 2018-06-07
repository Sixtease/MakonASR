#!/bin/bash

flac --decode -o - -- "$1" | oggenc -q 2 --downmix --resample 24000 -
