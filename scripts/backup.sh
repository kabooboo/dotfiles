#!/bin/bash

DRIVE_BACKUPS_DIR="1f2B8VTBIUg3rijL3kXt-da9XfOdIpKFs"

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
  --encrypt --recipient kabooboo \
  "${file}"
  rm $file
done;


for file in ${HOME}/Backups/ankh/*; do
  [[ $file == *.gpg ]] || continue
  gdrive upload --parent "${DRIVE_BACKUPS_DIR}" $file
done;
