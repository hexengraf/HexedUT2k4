#!/bin/sh

# Usage: sh build-package.sh "HexedNAME" "C:/UT2004/System" "C:/UT2004/System/ucc.exe"

set -e

hex=$PWD
sys=$2
ucc=${3:-"$2/ucc"}

for pkg in $1
do
  ver=$(sed -E "s/.*=[[:space:]]*$pkg([Vv0-9A-Za-z.-]*)$/\1/p;d" "$hex/$pkg/make.ini")

  ln -f -s "$hex/$pkg" "$sys/../$pkg$ver"

  rm -f "$sys/$pkg$ver".*
  "$ucc" make -ini="$hex/$pkg/make.ini"
  "$ucc" dumpint "$pkg$ver".u

  if [ -f "$hex/$pkg/template.int" ]; then
    sed "s/%/$pkg$ver/g" "$hex/$pkg/template.int" >> "$sys/$pkg$ver".int
  fi
done
