#!/bin/bash

flac --decode -o - -- "$1" | lame -h -m m --resample 24 -b 40 - -
