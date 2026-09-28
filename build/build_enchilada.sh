#!/usr/bin/env bash

set -uexo pipefail

url="https://dn721903.ca.archive.org/0/items/onepluscommunityserver/list/Unbrick_Tools/OnePlus_6/Pie/OnePlus_6_OxygenOS_9.0.zip"
zip_name="OnePlus_6_OxygenOS_9.0.zip"
ops_dir="enchilada_22_O.25_180915"

# build/patch.py, build/flash.sh, oppo_decrypt and the source zip are all
# resolved relative to THIS script's own location, not the current
# directory.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

work_dir="${script_dir}/oneplus_enchilada_pie"
if [[ -e "$work_dir" ]]; then
    echo "$work_dir already exists -- remove it or move it aside before rebuilding" >&2
    exit 1
fi
mkdir -- "$work_dir"
cd -- "$work_dir"

if [[ -f "${script_dir}/${zip_name}" ]]; then
    cp -- "${script_dir}/${zip_name}" .
else
    curl -LO "$url"
fi
7z x "$zip_name"

if [[ ! -d "${script_dir}/oppo_decrypt" ]]; then
    git clone https://github.com/bkerler/oppo_decrypt "${script_dir}/oppo_decrypt"
    python -m pip install -r "${script_dir}/oppo_decrypt/requirements.txt"
fi

python "${script_dir}/oppo_decrypt/opscrypto.py" decrypt "${ops_dir}/${ops_dir}.ops"
mv "${ops_dir}/extract" images
env --chdir=images python "${script_dir}/build/patch.py"
install -Dm 0755 "${script_dir}/build/flash.sh" flash.sh
7z a -mx9 oneplus_enchilada_pie.7z flash.sh images

echo "Done: ${work_dir}/oneplus_enchilada_pie.7z"
