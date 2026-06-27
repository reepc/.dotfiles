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

# ── conda: complete environment names ─────────────────────────────
# conda's zsh hook (in ~/.zshrc) doesn't register tab-completion, so
# `conda activate <TAB>` offers nothing useful. This adds a lightweight
# completion that lists environment names after `activate`/`deactivate` (and
# after a `-n`/`--name` flag). Standard _describe candidates, so fzf-tab
# renders them automatically — no auto-accept. `conda` is only invoked lazily
# when you press TAB, so this works even though it loads before conda's init.
_conda_envs() {
  local -a envs
  # `conda env list`: env name is column 1; comment/legend lines start with #.
  envs=(${(f)"$(conda env list 2>/dev/null | awk 'NF && $1 !~ /^#/ {print $1}')"})
  _describe -t conda-envs 'conda environment' envs
}

_conda() {
  local -a subcmds
  subcmds=(
    activate deactivate create remove install update upgrade
    list info env search run clean config init
  )

  # `-n <env>` / `--name <env>` anywhere on the line -> env names.
  if [[ "$words[CURRENT-1]" == (-n|--name) ]]; then
    _conda_envs
    return
  fi

  # First word after `conda` -> the subcommand.
  if (( CURRENT == 2 )); then
    _describe -t conda-subcmds 'conda command' subcmds
    return
  fi

  # Env names for the activate/deactivate subcommands; files otherwise.
  case "$words[2]" in
    activate|deactivate) _conda_envs ;;
    *) _default ;;
  esac
}
compdef _conda conda
