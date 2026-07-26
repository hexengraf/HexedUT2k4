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
cp -f "$pkg$ver".* "$out" 2>/dev/null || true
