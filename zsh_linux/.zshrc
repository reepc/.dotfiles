# ── Environment ──────────────────────────────────────────────────
export EDITOR="nvim"
export CUDA_DEVICE_ORDER=PCI_BUS_ID

# ── PATH (single source of truth, deduplicated) ──────────────────
typeset -U PATH
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
export PATH="/usr/local/cuda/bin:$PATH"
# export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# ── Homebrew (Linuxbrew) ──────────────────────────────────────────
# Must be early so $(brew --prefix) resolves correctly for plugin sourcing
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ── Completions ───────────────────────────────────────────────────
# Includes compinit — must come before plugins that hook into completion
source ~/.zsh_completions.zsh

# ── Plugins (via Homebrew) ────────────────────────────────────────
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-completions/zsh-completions.plugin.zsh 2>/dev/null || true

# ── Zoxide (replaces z) ──────────────────────────────────────────
eval "$(zoxide init zsh)"

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

# ── Custom commands ───────────────────────────────────────────────
[[ -f ~/.custom_commands.sh ]] && source ~/.custom_commands.sh

function show_custom_commands {
  echo "Custom Commands: "
  echo "----------- Functions -----------"
  awk '/^function [a-zA-Z0-9_]+\s*()/,/^}/' ~/.custom_commands.sh | sed -e 's/^/  /'
  echo "---------------------------------"
  echo
  echo "------------ Aliases ------------"
  grep -E '^alias [a-zA-Z0-9_]+=' ~/.custom_commands.sh | while read -r line; do
    echo "  $line"
  done
  echo "---------------------------------"
}

# ── Aliases (eza) ────────────────────────────────────────────────
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first --git"
alias la="eza -la --icons --group-directories-first --git"
alias lt="eza --tree --icons --level=2"

# ── NVM ──────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]             && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ]    && source "$NVM_DIR/bash_completion"

# ── Luarocks ─────────────────────────────────────────────────────
command -v luarocks &>/dev/null && eval "$(luarocks path --bin)"

# ── Bun ──────────────────────────────────────────────────────────
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# ── Conda ────────────────────────────────────────────────────────
__conda_setup="$('/home/reepc/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/reepc/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/reepc/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/reepc/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# ── Keybindings (always after plugins) ───────────────────────────
[ -f "$HOME/.zsh_keybindings.sh" ] && source "$HOME/.zsh_keybindings.sh"

# ── Starship (always last) ────────────────────────────────────────
eval "$(starship init zsh)"
