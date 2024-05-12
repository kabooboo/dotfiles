#!/bin/bash

DRIVE_BACKUPS_DIR="1SL0CzqKrB_yKC_NXfVpwUC3kylxApOHE"

declare -a TARGET_DIRS=(
  "Desktop"
  "Documents"
  ".dotfiles"
  "Downloads"
  ".local"
  "Music"
  "Pictures"
  ".secrets"
  "Videos"
  ".vscode"
)

cd "${HOME}"

for DIR in ${TARGET_DIRS[@]}; do
  echo "Backing up ${DIR}..."
  tar -czf "./Backups/ankh/${DIR/./}.tar.gz"  "./${DIR}"
done


for file in ${HOME}/Backups/ankh/*; do
  [[ $file != *.gpg ]] || continue
  echo "Encrypting backup ${file}..."
  gpg --batch --yes \
  --output "${file}.gpg" \
  --encrypt --recipient me@kaboo.boo \
  "${file}"
  rm $file
done;

gdrive sync upload ${HOME}/Backups/ankh "${DRIVE_BACKUPS_DIR}"
rsync -r ${HOME}/Backups/ankh /mnt/external/backups/ankh/ || true
