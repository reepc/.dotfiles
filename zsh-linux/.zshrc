
# ── Environment & PATH ───────────────────────────────────────────
# Env vars and the base PATH now live in ~/.zshenv so they apply to EVERY
# shell, including the non-interactive ones tmux popups use.

# Truecolor for the prompt: over plain ssh, Ghostty's ssh-env integration
# sets COLORTERM=truecolor, but mosh doesn't propagate it. Default it when
# unset (the mosh case) so Starship's hex colors render as 24-bit. Runs in
# every interactive shell, so tmux panes inherit it too.
export COLORTERM=${COLORTERM:-truecolor}

fpath=("$HOME/.zsh-completions/src" $fpath)

# ── Plugins ───────────────────────────────────────────────────────
# Install: sudo apt install zsh-autosuggestions zsh-syntax-highlighting
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Completions ───────────────────────────────────────────────────
# Includes compinit — must come before plugins that hook into completion
source ~/.zsh_completions.zsh

# ── fzf ──────────────────────────────────────────────────────────
eval "$(fzf --zsh)"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}' --preview-window=right:50%"
export FZF_TMUX_OPTS="-p 80%,60%"
export FZF_DEFAULT_OPTS="
  --color=fg:#abb2bf,bg:-1,hl:#61afef
  --color=fg+:#ffffff,bg+:#3e4452,hl+:#61afef
  --color=info:#98c379,prompt:#c678dd,pointer:#e06c75
  --color=marker:#e5c07b,spinner:#56b6c2,header:#56b6c2
  --color=border:#5c6370
"

# ── fzf-tab ───────────────────────────────────────────────────────
source ~/.fzf-tab/fzf-tab.plugin.zsh
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --tree --icons --level=2 -- $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-min-width 80
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always $realpath 2>/dev/null || eza --tree --icons $realpath'

# ── Inline completion menu ───────────────────────────────────────
# No tmux popup. fzf-tab renders its default inline list right under the
# prompt (with the previews configured above). This works identically inside
# and outside tmux and on any tmux version — unlike fzf's --tmux popup, which
# needs tmux >= 3.3 and on older tmux breaks completion (TAB leaks a newline).

# ── Zoxide (init + omz/zsh-z-style `z` tab completion) ────────────
# Sourced after compinit & fzf-tab so completion + preview work.
source ~/.zsh_zoxide.zsh

# ── Custom commands ───────────────────────────────────────────────
[[ -f ~/.custom_commands.sh ]] && source ~/.custom_commands.sh

# ── Aliases ───────────────────────────────────────────────────────
[[ -f ~/.zsh_alias.zsh ]] && source ~/.zsh_alias.zsh

function show_custom_commands {
  echo "Custom Commands: "
  echo "----------- Functions -----------"
  awk '/^function [a-zA-Z0-9_]+\s*()/,/^}/' ~/.custom_commands.sh | sed -e 's/^/  /'
  echo "---------------------------------"
  echo
  echo "------------ Aliases ------------"
  grep -E '^alias [a-zA-Z0-9_-]+=' ~/.zsh_alias.zsh | while read -r line; do
    echo "  $line"
  done
  echo "---------------------------------"
}

# ── NVM ──────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]          && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ── Luarocks ─────────────────────────────────────────────────────
command -v luarocks &>/dev/null && eval "$(luarocks path --bin)"

# ── Bun ──────────────────────────────────────────────────────────
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# ── Conda ────────────────────────────────────────────────────────
# Checks anaconda3 first (existing servers), falls back to miniconda3 (fresh installs)
if [[ -f "$HOME/anaconda3/bin/conda" ]]; then
  _conda_base="$HOME/anaconda3"
elif [[ -f "$HOME/miniconda3/bin/conda" ]]; then
  _conda_base="$HOME/miniconda3"
fi

if [[ -n "$_conda_base" ]]; then
  __conda_setup="$("$_conda_base/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  elif [ -f "$_conda_base/etc/profile.d/conda.sh" ]; then
    . "$_conda_base/etc/profile.d/conda.sh"
  else
    export PATH="$_conda_base/bin:$PATH"
  fi
  unset __conda_setup _conda_base
fi

# ── Keybindings (always after plugins) ───────────────────────────
[ -f "$HOME/.zsh_keybindings.sh" ] && source "$HOME/.zsh_keybindings.sh"

# ── Starship (always last) ────────────────────────────────────────
eval "$(starship init zsh)"
