#!/usr/bin/env bash
# Download test data, training data and trained models from the Google Drive
# links given in the PraNet and Polyp-PVT READMEs.
# Usage: bash scripts/download.sh <work_dir>
set -euo pipefail

WORK=${1:-/content/work}
mkdir -p "$WORK/downloads" "$WORK/data" "$WORK/weights"
cd "$WORK/downloads"

# PraNet README: TestDataset (5 sets), TrainDataset (Kvasir 900 + ClinicDB 550), PraNet-19.pth
[ -f TestDataset.zip ]  || gdown 1Y2z7FD5p5y31vkZwQQomXFRB0HutHyao -O TestDataset.zip
[ -f TrainDataset.zip ] || gdown 1YiGHLw4iTvKdvbT6MgwO9zcCv8zJ_Bnb -O TrainDataset.zip
[ -f "$WORK/weights/PraNet-19.pth" ] || gdown 1lJv8XVStsp3oNKZHaSr42tawdMOq6FLP -O "$WORK/weights/PraNet-19.pth"

# Polyp-PVT README: trained model (4.7) and PVTv2-B2 backbone (4.3, Polyp-PVT's
# constructor loads it from ./pretrained_pth even at test time)
[ -d pvt_trained ]  || gdown --folder 1xC5Opwu5Afz4xiK5O9v4NnQOZY0A9-2j -O pvt_trained
[ -d pvt_backbone ] || gdown --folder 1Eu8v9vMRvt-dyCH0XSV2i77lAd62nPXV -O pvt_backbone

find pvt_trained  -name '*.pth' -exec cp {} "$WORK/weights/PolypPVT.pth" \; -quit
find pvt_backbone -name 'pvt_v2_b2*.pth' -exec cp {} "$WORK/weights/pvt_v2_b2.pth" \; -quit

for z in TestDataset.zip TrainDataset.zip; do
  d="$WORK/data/${z%.zip}"
  [ -d "$d" ] || unzip -q "$z" -d "$WORK/data"
done
# Remove macOS metadata that some of the archives ship with
rm -rf "$WORK/data/__MACOSX"

ls -lh "$WORK/weights"
for s in CVC-300 CVC-ClinicDB Kvasir CVC-ColonDB ETIS-LaribPolypDB; do
  printf '%-18s images=%4s masks=%4s\n' "$s" \
    "$(ls "$WORK/data/TestDataset/$s/images" | wc -l)" \
    "$(ls "$WORK/data/TestDataset/$s/masks" | wc -l)"
done
