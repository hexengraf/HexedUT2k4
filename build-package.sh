#!/bin/sh

# Usage: sh build-package.sh "HexedNAME" "C:/UT2004/System" "C:/UT2004/System/ucc.exe"

set -e

hex=$PWD
pkg=$1
sys=$2
ucc=${3:-"$2/ucc"}
ver=$(sed -E "s/.*=[[:space:]]*$pkg([Vv0-9A-Za-z.-]*)$/\1/p;d" "$pkg/make.ini")

cd "$sys/.."

  ln -f -s "$hex/$pkg" "$pkg$ver"

cd "$sys"

  rm -f "$pkg$ver".*

  "$ucc" make -ini="../$pkg$ver/make.ini"
  "$ucc" dumpint "$pkg$ver".u

cd "$sys/.."

  if [ -f "$pkg$ver/template.int" ]; then
    sed "s/%/$pkg$ver/g" "$pkg$ver/template.int" >> "$sys/$pkg$ver".int
  fi
