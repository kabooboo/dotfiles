#!/bin/bash

declare -a TARGET_DIRS=(
  "Desktop"
  "Documents"
  ".dotfiles"
  "Downloads"
  ".local"
  "Music"
  "Pictures"
  "Projects"
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
