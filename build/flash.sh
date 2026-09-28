#!/usr/bin/env bash

set -uexo pipefail
which edl

shopt -s nullglob
pairs=(rawprogram*.xml)
if [[ ${#pairs[@]} -eq 0 ]]; then
    echo "No rawprogram*.xml files found -- did patch.py run first?" >&2
    exit 1
fi

for rawprogram in "${pairs[@]}"; do
    n=${rawprogram#rawprogram}
    n=${n%.xml}
    patch="patch${n}.xml"
    if [[ ! -f "$patch" ]]; then
        echo "Missing $patch for $rawprogram -- refusing to flash a partial set" >&2
        exit 1
    fi
    edl qfil "$rawprogram" "$patch" images
done
