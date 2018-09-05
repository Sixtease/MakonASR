#!/bin/bash

oggenc -q 2 --downmix --resample 24000 -o - -- "$1"
