#!/bin/sh

# Usage: sh extract-package.sh "HexedNAME" "build/System" "C:/UT2004/System"

set -e

hex=$PWD
pkg=$1
out=$2
sys=$3
ver=$(sed -E "s/.*=[[:space:]]*$pkg([Vv0-9A-Za-z.-]*)$/\1/p;d" "$pkg/make.ini")

mkdir -p "$out"

cd "$sys"

  #mv -f "$pkg$ver".u "$pkg$ver".ucl "$pkg$ver".int "$out" 2>/dev/null || true
  cp -f "$pkg$ver".* "$out" 2>/dev/null || true
  #cp -f ucc.log StdOut.log "$out"

exit

cd "$out"

  for file in *"$ver"*; do
    mv "$file" $(printf '%s\n' "$file" | sed "s/$ver//g")
  done

#cd "$sys/.."

  #rm -R "$pkg$ver"
  #rm -f "$pkg$ver"
