#!/bin/bash

: ${SS:='<s>'}
: ${SE:='</s>'}

n=`wc -l "$@" | tail -n 1 | awk '{ print $1 }'`

paste -d ' ' <(yes "$SS" | head -n $n) <(cat "$@") <(yes "$SE" | head -n "$n")
