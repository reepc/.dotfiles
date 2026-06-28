# Custom Function
function delete_tmux_session {
  tmux kill-session -a
  tmux rename-session 0
}

# Custom Command
alias ca="conda activate"
alias cda="conda deactivate"
alias py3="python3"
alias treet="tree -I 'node_modules|__pycache__|.nuxt|dist|.next|target|icons'"
alias clean_mem="pkill -f 'Visual Studio Code'"
alias activate="source .venv/bin/activate"
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first --git"
alias la="eza -la --icons --group-directories-first --git"
alias lt="eza --tree --icons --level=2"
