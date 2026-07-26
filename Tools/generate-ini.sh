#!/bin/sh

pkg_name=$1
ini_file=$2
shift 2
dependencies=$@

# Initialize with boilerplate
cat << EOF > "${ini_file}"
[Engine.Engine]
EditorEngine=Editor.EditorEngine

[Core.System]
SavePath=../Save
CachePath=../Cache
CacheExt=.uxx
CacheRecordPath=../System/*.ucl
MusicPath=../Music
SpeechPath=../Speech
Paths=../System/*.u
Paths=../Maps/*.ut2
Paths=../Textures/*.utx
Paths=../Sounds/*.uax
Paths=../Music/*.umx
Paths=../StaticMeshes/*.usx
Paths=../Animations/*.ukx
Paths=../Saves/*.uvx

[Editor.EditorEngine]
EditPackages=Core
EditPackages=Engine
EOF

# List all package dependencies
for d in ${dependencies}; do
    echo "EditPackages=${d}" >> "${ini_file}"
done

# List the target package as the last one
echo "EditPackages=${pkg_name}" >> "${ini_file}"
