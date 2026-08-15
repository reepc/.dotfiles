# Custom Function
# Aliases now live in ~/.zsh_alias.zsh (stowed from common/.zsh_alias.zsh).
function delete_tmux_session {
  tmux kill-session -a
  tmux rename-session 0
}
