# ── PATH (interactive priorities) ────────────────────────────────
# Environment vars and the base PATH (system + cargo + Homebrew) live in
# ~/.zshenv so they apply to EVERY shell, including the non-interactive ones
# tmux popups use. Here we just move the interactive-priority dirs to the
# FRONT so Homebrew tools win over the system ones in your interactive shell.
typeset -U path PATH
path=(
  /opt/homebrew/opt/llvm/bin
  /opt/homebrew/opt/openjdk/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $HOME/.local/bin
  $HOME/.console-ninja/.bin
  $path
)
export PATH

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

# ── Inline completion menu ───────────────────────────────────────
# No tmux popup. fzf-tab renders its default inline list right under the
# prompt (with the previews configured above). This works identically inside
# and outside tmux and on any tmux version — unlike fzf's --tmux popup, which
# needs tmux >= 3.3 and on older tmux breaks completion (TAB leaks a newline).

# ── Zoxide (init + omz/zsh-z-style `z` tab completion) ────────────
# Sourced after compinit & fzf-tab so completion + preview work.
source ~/.zsh_zoxide.zsh

# ── Custom commands ───────────────────────────────────────────────
if [[ -f ~/.custom_commands.sh ]]; then
  . ~/.custom_commands.sh
fi

# ── Local overrides (untracked, per-machine — network/host secrets) ─
[[ -f ~/.zsh_local.zsh ]] && source ~/.zsh_local.zsh

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

# pnpm
export PNPM_HOME="/Users/reepc/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
