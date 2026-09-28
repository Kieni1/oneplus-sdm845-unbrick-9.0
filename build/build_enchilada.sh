#!/usr/bin/env bash

set -uexo pipefail

# Usage: ./build_enchilada.sh [pie|q]
#   pie -> OOS 9.0     (needed for the SailfishOS/TWRP install guide)
#   q   -> OOS 10.3.8  (kept only as a fallback/reference)
# Defaults to pie.
variant="${1:-pie}"

case "$variant" in
  pie)
    url="https://dn721903.ca.archive.org/0/items/onepluscommunityserver/list/Unbrick_Tools/OnePlus_6/Pie/OnePlus_6_OxygenOS_9.0.zip"
    zip_name="OnePlus_6_OxygenOS_9.0.zip"
    ops_dir="enchilada_22_O.25_180915"
    ;;
  q)
    url="https://archive.org/download/onepluscommunityserver/list/Unbrick_Tools/OnePlus_6/Q/OnePlus_6_OxygenOS_10.3.8.zip"
    zip_name="OnePlus_6_OxygenOS_10.3.8.zip"
    ops_dir="enchilada_22_J.50_210121"
    ;;
  *)
    echo "Unknown variant '$variant' -- expected 'pie' or 'q'" >&2
    exit 1
    ;;
esac

# Resolve build/patch.py, build/flash.sh and oppo_decrypt relative to THIS
# script's own location, not the current directory -- so it doesn't matter
# how deep the per-variant work directory below is nested, and both
# variants can share one oppo_decrypt checkout.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Each variant gets its own directory so a Pie run can never partially
# overwrite files from an earlier Q run (or vice versa) -- flashing a mix
# of images from two different firmware versions is worse than the
# version-mismatch problem this script exists to fix.
work_dir="${script_dir}/oneplus_enchilada_${variant}"
if [[ -e "$work_dir" ]]; then
    echo "$work_dir already exists -- remove it or move it aside before rebuilding" >&2
    exit 1
fi
mkdir -- "$work_dir"
cd -- "$work_dir"

curl -LO "$url"
7z x "$zip_name"

if [[ ! -d "${script_dir}/oppo_decrypt" ]]; then
    git clone https://github.com/bkerler/oppo_decrypt "${script_dir}/oppo_decrypt"
    python -m pip install -r "${script_dir}/oppo_decrypt/requirements.txt"
fi

python "${script_dir}/oppo_decrypt/opscrypto.py" decrypt "${ops_dir}/${ops_dir}.ops"
mv "${ops_dir}/extract" images
env --chdir=images python "${script_dir}/build/patch.py"
install -Dm 0755 "${script_dir}/build/flash.sh" flash.sh
7z a -mx9 "oneplus_enchilada_${variant}.7z" flash.sh images

echo "Done: ${work_dir}/oneplus_enchilada_${variant}.7z"
