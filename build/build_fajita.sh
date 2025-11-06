#!/usr/bin/env bash

set -uexo pipefail

curl -LO https://dn721903.ca.archive.org/0/items/onepluscommunityserver/list/Unbrick_Tools/OnePlus_6T/Q/OnePlus_6T_OxygenOS_10.3.8.zip
7z x OnePlus_6T_OxygenOS_10.3.8.zip
git clone https://github.com/bkerler/oppo_decrypt
python -m pip install -r oppo_decrypt/requirements.txt
python oppo_decrypt/opscrypto.py decrypt fajita_41_J.50_210121/fajita_41_J.50_210121.ops
mv fajita_41_J.50_210121/extract images
env --chdir=images python ../build/patch.py
install -Dm 0755 build/flash.sh flash.sh
7z a -mx9 oneplus_fajita.7z flash.sh images
