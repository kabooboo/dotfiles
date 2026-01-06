export LC_ALL=fr_FR.UTF-8
export EDITOR="nano"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# auto-complete stuff
source <(yak completion zsh)
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
source "$(gcloud info --format='value(installation.sdk_root)')/path.zsh.inc"
source "$(gcloud info --format='value(installation.sdk_root)')/completion.zsh.inc"
source <(fzf --zsh)
source <(kubectl completion zsh)
source <(k completion zsh)
source <(k9s completion zsh)

# starship
eval "$(starship init zsh)"
eval "$(mise activate zsh)"

# aliases
alias python="uv run python"
alias ktx="kubectl ctx"
alias kns="kubectl ns"
alias k=kubectl
alias dc="docker compose"
alias d=docker
alias copy=pbcopy
alias git-checkout='git branch | grep -v "^\*" | fzf --height=20% --reverse --info=inline | xargs git checkout'
alias mi='mise run'

# functions
yoink() {
  # Display help if no arguments provided
  if [[ $# -eq 0 ]]; then
    echo "Usage: yoink <source> [target_name]"
    echo "  <source>     : File or folder to move to ~/.dotfiles"
    echo "  [target_name]: Name to use in ~/.dotfiles (optional)"
    echo "                 If not provided, basename of source will be used"
    return 1
  fi

  local source="$1"
  local dotfiles_dir="$HOME/.dotfiles"

  # Check if source exists
  if [[ ! -e "$source" ]]; then
    echo "Error: Source '$source' does not exist."
    return 1
  fi

  # Create .dotfiles directory if it doesn't exist
  if [[ ! -d "$dotfiles_dir" ]]; then
    mkdir -p "$dotfiles_dir"
    echo "Created directory: $dotfiles_dir"
  fi

  # Determine target name
  local target_name
  if [[ -n "$2" ]]; then
    target_name="$2"
  else
    # Extract filename from path and remove leading dots: ${source:t} gets the basename, ##*. strips everything up to the last dot
    target_name=${${source:t}##*.}
  fi

  local target_path="$dotfiles_dir/$target_name"

  # Check if target already exists
  if [[ -e "$target_path" ]]; then
    echo "Error: Target '$target_path' already exists."
    return 1
  fi

  # Move the source to target
  mv "$source" "$target_path"

  if [[ $? -eq 0 ]]; then
    echo "Successfully moved '$source' to '$target_path'"
  else
    echo "Error: Failed to move '$source' to '$target_path'"
    return 1
  fi

  $HOME/.dotfiles/install

}

aws-profile() {
  eval $(grep -E '^\[profile [a-zA-Z][a-zA-Z_-]+\]' "${HOME}/.aws/config" | awk -F"[][]" '{print $2}' |while read a p ; do echo "export AWS_PROFILE=$p" ; done  |
  fzf +s --tac )
}

# A function to visually change directories with lstr
lcd() {
    # Run lstr and capture the selected path into a variable.
    # The TUI will draw on stderr, and the final path will be on stdout.
    local selected_dir
    selected_dir="$(lstr interactive -gG --icons -s -p)"

    # If the user selected a path (and didn't just quit), `cd` into it.
    # Check if the selection is a directory.
    if [[ -n "$selected_dir" && -d "$selected_dir" ]]; then
        cd "$selected_dir"
    fi
}

image_with_sha() {
      local image_name="$1"
      if [[ -z "$image_name" ]]; then
          echo "Usage: get_image_sha <image-name>"
          return 1
      fi

      local sha=$(docker manifest inspect
  "$image_name" | jq -r '.config.digest')
      if [[ "$sha" != "null" && -n "$sha" ]]; then
          echo "${image_name}@${sha}"
      else
          echo "Error: Could not retrieve SHA for
  image $image_name" >&2
          return 1
      fi
}

ray_dashboard() {
  open http://localhost:8265 & k ray session $(k get raycluster -o name | sed 's%raycluster.ray.io/%%g') -n $(kubectl config view --minify --output 'jsonpath={..namespace}')
}
