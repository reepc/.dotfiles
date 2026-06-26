# =====================================================================
#  ~/.zshenv  (Linux)
#  Sourced for EVERY zsh: login, non-login, interactive, scripts, and
#  — crucially — the non-interactive shells that tmux popups spawn
#  (e.g. tmux-fzf's preview). Keep this limited to environment + PATH so
#  tools resolve everywhere. Interactive-only setup lives in ~/.zshrc.
# =====================================================================

# ── Environment ──────────────────────────────────────────────────
export EDITOR="nvim"
export CUDA_DEVICE_ORDER=PCI_BUS_ID

# ── PATH (single source of truth) ────────────────────────────────
# Put user/tool dirs ahead of the system base so every shell (incl. tmux
# popups) finds locally-installed tools: fzf & bat (~/.local/bin), nvim
# (/usr/local/bin), CUDA, etc. conda is intentionally NOT here — it only
# activates in ~/.zshrc, so tmux/scripts keep a predictable python.
typeset -U path PATH          # auto-dedupe PATH entries
path=(
  $HOME/.local/bin
  $HOME/bin
  /usr/local/bin
  /usr/local/cuda/bin
  $path
)
export PATH

# export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64:$LD_LIBRARY_PATH
