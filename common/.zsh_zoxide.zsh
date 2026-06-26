# ============================================================================
# Zoxide  —  `z <kw>` jumps; pressing <TAB> on a `z` command opens an fzf list
# rendered by *fzf-tab*, exactly like every other completion. One source of
# truth: the `:fzf-tab:*` zstyles drive the look/preview for commands, `cd`
# AND `z` alike — edit fzf-tab config once, it applies everywhere.
#
# Why an override is needed: zoxide's stock completion (`__zoxide_z_complete`,
# emitted by `zoxide init zsh`) calls `zoxide query --interactive`, i.e. its
# OWN fzf (configured via _ZO_FZF_OPTS) and auto-accepts the pick — bypassing
# fzf-tab and all of its previews/zstyles. We replace it with a plain
# completion that hands the zoxide database to the completion system as
# candidates, letting fzf-tab take over.
#
# Behaviour:
#   z <TAB>        → fzf-tab list of the whole frecency-ranked database
#   z <kw><TAB>    → fzf-tab list of zoxide's matches for <kw> (NOT auto-jump)
#   z <localdir>   → falls back to normal directory completion when zoxide has
#                    no match, so literal paths still complete like `cd`
#
# Must be sourced AFTER `compinit` and AFTER fzf-tab (see .zshrc), so that our
# `compdef` overrides zoxide's and fzf-tab is the active Tab handler.
# ============================================================================

eval "$(zoxide init zsh)"

# ── Feed the zoxide database to the completion system ───────────────────────
# Overrides zoxide's `compdef __zoxide_z_complete z` (run just above).
#
# We let ZOXIDE do the keyword matching (`zoxide query --list -- <kw>`): it
# ranks by frecency and matches keywords against any path component, which is
# far better than zsh's matcher trying to match a bare word against absolute
# paths (that silently dropped everything for `z <kw><TAB>`).
#
# compadd flags:
#   -U  : insert unconditionally — don't let zsh re-filter by the typed prefix
#         and discard zoxide's matches (the whole point; the typed word is
#         replaced by the chosen path on accept).
#   -f  : candidates are filenames, so fzf-tab resolves `$realpath` for previews
#         and quotes paths containing spaces correctly.
#   -V zoxide : unsorted group, preserving zoxide's frecency order.
_zoxide_z_complete() {
  emulate -L zsh
  # Keywords after `z`; unquoted expansion drops the trailing empty cursor word.
  local -a kw dirs
  kw=(${words[2,-1]})
  dirs=("${(@f)$(\command zoxide query --list --exclude "${PWD}" -- "$kw[@]" 2>/dev/null)}")
  if (( $#dirs )); then
    compadd -U -f -V zoxide -a dirs
  else
    _files -/   # no zoxide match → complete local directories, like `cd`
  fi
}
compdef _zoxide_z_complete z

# ── Preview for the `z` list ────────────────────────────────────────────────
# Mirrors the `cd` preview. fzf runs previews via `$SHELL -c`, a non-interactive
# shell that does NOT load ~/.zshrc, so a bare `eza` may not be on PATH there —
# bake in its absolute path now (PATH is set up). `$realpath` is expanded by
# fzf-tab at preview time, so it must stay literal (escaped here).
zstyle ':fzf-tab:complete:z:*' fzf-preview \
  "${commands[eza]:-eza} --color=always --tree --icons --level=2 -- \$realpath 2>/dev/null || ls -la \$realpath"
zstyle ':fzf-tab:complete:z:*' fzf-min-width 80
