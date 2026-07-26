#!/bin/sh

# Usage:
# Makefile.sh build "HexedNAME" "build/System" "C:/UT2004/System" "$UCC"
#             extract "HexedNAME" "build/System" "C:/UT2004/System"
#             compress "HexedNAME" "build" "C:/UT2004/System" "$UCC"

set -e

check() {
  if test -n "$UT2004"
  then
    printf '%s\n' "Build with 'make all'" && exit 0
  else
    printf '\033[31m%s\033[m\n' "Must specify installation path with \"UT2004\" environment variable" >&2 && exit 1
  fi
}

build() {
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
}

extract() {
  out=$2
  sys=$3

  for pkg in $1
  do
    ver=$(sed -E "s/.*=[[:space:]]*$pkg([Vv0-9A-Za-z.-]*)$/\1/p;d" "$pkg/make.ini")
    cp -f "$sys/$pkg$ver".* "$out" 2>/dev/null || true
  done
}

compress() {
  out=$2
  sys=$3
  ucc=${4:-"$3/ucc"}

  for pkg in $1
  do
    ver=$(sed -E "s/.*=[[:space:]]*$pkg([Vv0-9A-Za-z.-]*)$/\1/p;d" "$pkg/make.ini")
    rm -f "$sys/$pkg$ver".u.uz2
    "$ucc" compress "$pkg$ver".u
    mv -f "$sys/$pkg$ver".u.uz2 "$out/$pkg".u.uz2
  done
}

cmd=$1
shift
case "$cmd" in
     "check") check "$@" ;;
     "build") build "$@" ;;
   "extract") extract "$@" ;;
  "compress") compress "$@" ;;
           *) printf '\033[31m%s\033[m\n' "$0: Unrecognized command \"$cmd\"" >&2 ;;
esac
