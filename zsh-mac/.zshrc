# ── Environment ──────────────────────────────────────────────────
export EDITOR="nvim"
export MECABRC=/opt/homebrew/etc/mecabrc

# ── PATH (single source of truth, deduplicated) ──────────────────
typeset -U PATH
[[ ":$PATH:" != *":$HOME/.console-ninja/.bin:"* ]] && export PATH="$HOME/.console-ninja/.bin:$PATH"
[[ ":$PATH:" != *":$HOME/.local/bin:"*           ]] && export PATH="$HOME/.local/bin:$PATH"
[[ ":$PATH:" != *":/opt/homebrew/bin:"*          ]] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

source ~/.zsh_completions.zsh

# ── Oh My Zsh plugins (now sourced directly via brew) ────────────
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-completions/zsh-completions.plugin.zsh 2>/dev/null || true

# ── Tools ────────────────────────────────────────────────────────
. "$HOME/.turso/env"

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

# ── fzf-tab ──────────────────────────────────────────────────────────
source ~/.fzf-tab/fzf-tab.plugin.zsh
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview '/opt/homebrew/bin/eza --color=always --tree --icons --level=2 -- $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-min-width 80
zstyle ':fzf-tab:complete:*:*' fzf-preview '/opt/homebrew/bin/bat --color=always $realpath 2>/dev/null || '/opt/homebrew/bin/eza' --tree --icons $realpath'

# ── Zoxide (init + omz/zsh-z-style `z` tab completion) ────────────
# Sourced after compinit & fzf-tab so completion + preview work.
source ~/.zsh_zoxide.zsh

# ── Custom commands ───────────────────────────────────────────────
if [[ -f ~/.custom_commands.sh ]]; then
  . ~/.custom_commands.sh
fi

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

[ -f $HOME/.zsh_keybindings.sh ] && source "$HOME/.zsh_keybindings.sh"

# ── Luarocks ─────────────────────────────────────────────────────
eval "$(luarocks path --bin)"

# ── Bun ──────────────────────────────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ── Conda ────────────────────────────────────────────────────────
# >>> conda initialize >>>
__conda_setup="$('/Users/reepc/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/reepc/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/reepc/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/reepc/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# ── Starship (always last) ────────────────────────────────────────
eval "$(starship init zsh)"
