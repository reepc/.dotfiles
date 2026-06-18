# ============================================================================
# Zoxide  —  `z <kw>` jumps; pressing <TAB> on a `z` command opens an fzf list
# you choose from yourself (it never auto-jumps to the top match).
#
# Implemented as a Tab ZLE widget rather than a completion: completion would
# auto-insert the best match when the typed word is empty, which is exactly the
# behaviour we want to avoid. For every command other than `z`, Tab falls back
# to its normal binding (fzf-tab), so nothing else changes.
#
# Must be sourced AFTER `compinit` and AFTER fzf-tab (see .zshrc), so that the
# fallback below captures fzf-tab's Tab binding.
# ============================================================================

eval "$(zoxide init zsh)"

# Remember whatever Tab is bound to right now (fzf-tab) so we can delegate to it
# for non-`z` commands. Guarded so re-sourcing can't make the widget recurse
# into itself. We bind into the `emacs` keymap because ~/.zsh_keybindings.sh
# runs `bindkey -e` later, which makes emacs the active keymap — binding `main`
# here would be clobbered by that switch.
typeset -g _ZOXIDE_TAB_FALLBACK
if [[ "${${(s: :)$(bindkey -M emacs '^I')}[-1]}" != _zoxide_z_fzf ]]; then
  _ZOXIDE_TAB_FALLBACK="${${(s: :)$(bindkey -M emacs '^I')}[-1]:-expand-or-complete}"
fi

_zoxide_z_fzf() {
  emulate -L zsh
  local -a toks=(${(z)LBUFFER})

  # Only hijack Tab when completing an argument of `z` (e.g. "z " or "z foo").
  if [[ ${toks[1]} == z && $LBUFFER == z[[:space:]]* ]]; then
    local query="${(j: :)toks[2,-1]}"
    local sel

    # fzf runs the preview via `$SHELL -c`, a non-interactive shell that does NOT
    # load ~/.zshrc — so a bare `eza` isn't on PATH there (it falls back to ls).
    # Resolve eza's absolute path now (PATH is set up) and bake it in, matching
    # the `cd` preview. Cross-platform: works wherever eza is installed.
    local eza=${commands[eza]:-ls}

    # List the whole database (minus the current dir) and fuzzy-pick. fzf quotes
    # {} for us, so paths with spaces work. fzf inherits $FZF_DEFAULT_OPTS.
    sel=$(
      \command zoxide query --list --exclude "${PWD}" 2>/dev/null \
        | fzf --height=45% --layout=reverse --border --info=inline \
              --query="$query" \
              --bind 'tab:down,btab:up' \
              --preview-window=right:55% \
              --preview "${eza} --color=always --tree --icons --level=2 -- {} 2>/dev/null || ls -la {}"
    )

    if [[ -n $sel ]]; then
      BUFFER="z ${(q)sel}"
      CURSOR=$#BUFFER
      zle accept-line                  # pick → jump
    else
      zle reset-prompt                 # cancelled (Esc) → leave the line as-is
    fi
    return
  fi

  # Anything that isn't a `z` argument: behave exactly as before.
  zle "${_ZOXIDE_TAB_FALLBACK:-expand-or-complete}"
}

zle -N _zoxide_z_fzf
bindkey -M emacs '^I' _zoxide_z_fzf
