#!/bin/sh

# Usage: sh compress-package.sh "HexedNAME" "build" "C:/UT2004/System" "$UCC"

set -e

out=$2
sys=$3
ucc=${4:-"$3/ucc"}

mkdir -p "$out"

for pkg in $1
do
  ver=$(sed -E "s/.*=[[:space:]]*$pkg([Vv0-9A-Za-z.-]*)$/\1/p;d" "$pkg/make.ini")
  rm -f "$sys/$pkg$ver".u.uz2
  "$ucc" compress "$pkg$ver".u
  mv -f "$sys/$pkg$ver".u.uz2 "$out/$pkg".u.uz2
done
