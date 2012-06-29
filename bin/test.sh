#!/bin/bash

. "$EV_homedir/config.sh"

make -f "$EV_homedir/Makefile" test
