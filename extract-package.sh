#!/bin/sh

# Usage: sh extract-package.sh "HexedNAME" "build/System" "C:/UT2004/System"

set -e

out=$2
sys=$3

mkdir -p "$out"

for pkg in $1
do
  ver=$(sed -E "s/.*=[[:space:]]*$pkg([Vv0-9A-Za-z.-]*)$/\1/p;d" "$pkg/make.ini")
  cp -f "$sys/$pkg$ver".* "$out" 2>/dev/null || true
done
