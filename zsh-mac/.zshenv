# =====================================================================
#  ~/.zshenv  (macOS)
#  Sourced for EVERY zsh: login, non-login, interactive, scripts, and
#  — crucially — the non-interactive shells that tmux popups spawn
#  (e.g. tmux-fzf's preview). Keep this limited to environment + PATH so
#  tools resolve everywhere. Interactive-only setup lives in ~/.zshrc.
# =====================================================================

# ── Environment ──────────────────────────────────────────────────
export EDITOR="nvim"
export MECABRC=/opt/homebrew/etc/mecabrc

# ── PATH (single source of truth) ────────────────────────────────
# Start from a CLEAN system base so non-interactive shells (tmux popups,
# scripts) don't inherit a polluted PATH where the wrong python wins.
# NOTE: conda is intentionally NOT here — it only activates in ~/.zshrc,
# so tmux/scripts keep the predictable system python3.
typeset -U path PATH          # auto-dedupe PATH entries
unset PATH
eval "$(/usr/libexec/path_helper -s)"   # system base: /usr/bin, /bin, ...

# Rust toolchain, available to every shell.
export PATH="$HOME/.cargo/bin:$PATH"

# Homebrew APPENDED at the end: makes brew tools (tmux, fzf, eza, bat, ...)
# findable in non-interactive shells WITHOUT overriding the system python3.
# Interactive shells (~/.zshrc) re-prioritise Homebrew to the front.
[ -x /opt/homebrew/bin/brew ] && export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
