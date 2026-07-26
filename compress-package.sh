#!/bin/sh

# Usage: sh compress-package.sh "HexedNAME" "build" "C:/UT2004/System" "$UCC"

set -e

hex=$PWD
pkg=$1
out=$2
sys=$3
ucc=${4:-"$3/ucc"}
ver=$(sed -E "s/.*=[[:space:]]*$pkg([Vv0-9A-Za-z.-]*)$/\1/p;d" "$pkg/make.ini")

mkdir -p "$out"
cd "$sys"
rm -f "$pkg$ver".u.uz2
"$ucc" compress "$pkg$ver".u
mv -f "$pkg$ver".u.uz2 "$out/$pkg".u.uz2
