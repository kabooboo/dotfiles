# Setup fzf
# ---------
if [[ ! "$PATH" == */home/gcreti/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/gcreti/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/gcreti/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/gcreti/.fzf/shell/key-bindings.zsh"
