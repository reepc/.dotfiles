# ── Completion system init ────────────────────────────────────────
autoload -U compinit && compinit

# ── Case-insensitive matching ─────────────────────────────────────
# Lowercase input matches uppercase (pro → Projects)
# Also handles partial path completion (p/p/b → path/to/bar)
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*'

# ── Menu selection ────────────────────────────────────────────────
# Arrow-navigate through candidates instead of cycling
zstyle ':completion:*' menu select

# ── Colors ────────────────────────────────────────────────────────
# Use LS_COLORS so file completions match your ls colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ── Grouping and descriptions ─────────────────────────────────────
# Group completions by kind (files, commands, options…)
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches: %d%f'

# ── Caching ───────────────────────────────────────────────────────
# Speeds up completions for slow sources (git branches, etc.)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# ── Misc behaviour ────────────────────────────────────────────────
# Keep cursor at end of word on completion
setopt COMPLETE_IN_WORD
# Move cursor to end after completing
setopt ALWAYS_TO_END
# Don't beep on ambiguous completions
setopt NO_LIST_BEEP
