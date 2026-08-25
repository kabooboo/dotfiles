export LC_ALL=fr_FR.UTF-8
export EDITOR="nano"
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true

ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# auto-complete stuff (cached; `rm ~/.cache/zsh-completions.zsh` to refresh)
_zcomp=$HOME/.cache/zsh-completions.zsh
if [[ ! -s $_zcomp || -n $_zcomp(#qN.md+7) ]]; then
  { yak completion zsh
    uv generate-shell-completion zsh
    uvx --generate-shell-completion zsh
    fzf --zsh
    kubectl completion zsh
    k9s completion zsh
    starship init zsh
  } >| $_zcomp
fi
source $_zcomp
compdef k=kubectl

_gcloud=(${HOME}/.local/share/mise/installs/gcloud/*(/On))
if (( $#_gcloud )); then
  source $_gcloud[1]/path.zsh.inc
  source $_gcloud[1]/completion.zsh.inc
fi
unset _zcomp _gcloud

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
alias claude="claude --model claude-opus-5"

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

# Stream logs from pods matching selected labels
klogs() {
  local ns=$(kubectl config view --minify -o jsonpath='{..namespace}')
  ns=${ns:-default}

  # Check if pods exist
  if ! kubectl get pods --no-headers 2>/dev/null | grep -q .; then
    echo "No pods found in namespace '$ns'"
    return 1
  fi

  # Get unique label key=value pairs (common app labels first, then all others)
  local labels=$(kubectl get pods -o json | jq -r '
    [.items[].metadata.labels | to_entries[]]
    | group_by("\(.key)=\(.value)")
    | map(.[0] | "\(.key)=\(.value)")
    | sort_by(
        if test("^(app|app.kubernetes.io/name|kubernetes.io/app|component|service|name)=")
        then "0" + . else "1" + . end
      )
    | .[]
  ')

  if [[ -z "$labels" ]]; then
    echo "No labels found on pods in namespace '$ns'"
    return 1
  fi

  # Use fzf to select a label
  local selected=$(echo "$labels" | fzf \
    --height=40% \
    --reverse \
    --header="Select label for: kubectl logs -f --tail 0 -l <label> (ns: $ns)" \
    --preview="kubectl get pods -l {} -o wide 2>/dev/null" \
    --preview-window=down:30%)

  if [[ -z "$selected" ]]; then
    return 0
  fi

  echo "Running: kubectl logs -f --tail 0 -l '$selected'"
  kubectl logs -f --tail 0 -l "$selected"
}

