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
  "Public"
  ".secrets"
  "Videos"
  ".vscode"
)


for DIR in ${TARGET_DIRS[@]}; do
  tar -czvf "${HOME}/Backups/ankh/${DIR/./}.tar.gz"  "${HOME}/${DIR}"
done
