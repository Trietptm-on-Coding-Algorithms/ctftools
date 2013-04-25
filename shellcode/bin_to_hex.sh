#!/bin/sh

if [ $# -eq 0 ]
then
  xxd -g1 | cut -b9-56 | tr -d '\n' | sed -e 's/ *$//' -e 's/ /\\x/g'
else
  xxd -g1 $1 | cut -b9-56 | tr -d '\n' | sed -e 's/ *$//' -e 's/ /\\x/g'
fi
