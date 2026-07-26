#!/bin/sh

out_dir=$1
pkg_name=$2
pkg_tag=$3
out_regex=$4
shift 4
ucc="${@-UCC.exe}"

# List all mutator classes
mutators=$(find "${out_dir}/${pkg_name}/Classes/" -name "Mut*.uc")

# Replace %TAG% with the actual tag in all mutator classes
for m in $mutators; do
    sed -i -r "s/%TAG%/${pkg_tag}/g" "${m}"
done

# Save current working directory and enter System
work_dir=$(pwd)
cd "${out_dir}/System"
# Remove old package files to make sure UCC will generate fresh ones
rm -f "${pkg_name}.u" "${pkg_name}.ucl"
# Compile the package
${ucc} make -ini="../${pkg_name}.ini" -log="../${pkg_name}.log" | grep -Ei "${out_regex}"
# Export localization file (international english)
${ucc} dumpint "${pkg_name}.u" | grep -Ei "${out_regex}"

# Append additional information to the localization file (if any)
if [ -f "../${pkg_name}/Template.int" ]; then
    # Replace any %PKG% occurrences with the actual package name
    sed -r "s/%PKG%/${pkg_name}/g" "../${pkg_name}/Template.int" >> "${pkg_name}.int";
fi

# Return to the working directory
cd "${work_dir}"

for m in $mutators; do
    # Undo %TAG% replacements
    sed -i -r "s/${pkg_tag}/%TAG%/g" "${m}"
    # Fix timestamps to satisfy make
    touch -r "${out_dir}/System/${pkg_name}.u" "${m}"
done
