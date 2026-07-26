#!/bin/sh
find -name "Textures" -type f -delete
find -name "Textures" -type l -delete
find -name "Sounds" -type f -delete
find -name "Sounds" -type l -delete
CWD=$$(echo "$(PWD)" | sed 's,/,\\,g')
cmd /c "mklink /d HexedSRC\Textures $$CWD\Resources\Textures"
cmd /c "mklink /d HexedUT\Textures $$CWD\Resources\Textures"
cmd /c "mklink /d HexedUT\Sounds $$CWD\Resources\Sounds"
cmd /c "mklink /d HexedPatches\Textures $$CWD\Resources\Textures"
