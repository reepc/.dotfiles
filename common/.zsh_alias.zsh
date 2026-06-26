# ── Aliases ──────────────────────────────────────────────────────
# Shared across macOS and Linux. Sourced from both .zshrc files.

# ── General ──────────────────────────────────────────────────────
alias ca="conda activate"
alias cda="conda deactivate"
alias py3="python3"
alias treet="tree -I 'node_modules|__pycache__|.nuxt|dist|.next|target|icons'"
alias clean_mem="pkill -f 'Visual Studio Code'"
alias activate="source .venv/bin/activate"
alias autossh_connect="autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3'"

# ── eza (modern ls) ──────────────────────────────────────────────
# Functions, not aliases, for two reasons:
#   1. "${@:-.}" defaults the path to "." when none is given. Without an
#      explicit path AND a non-tty stdin (scripts, `while read`, subshells),
#      eza switches to --stdin mode and reads filenames from stdin instead of
#      listing the dir — so `ls | grep foo` would silently print nothing.
#   2. --icons=auto drops the icon glyphs when output isn't a terminal, so a
#      piped `ls | grep` stays clean (bare --icons keeps them always on).
# zsh refuses to define a function whose name is an existing alias, so clear
# any prior definitions first (keeps re-sourcing this file safe).
unalias ls ll la lt 2>/dev/null
ls() { eza --icons=auto --group-directories-first "${@:-.}"; }
ll() { eza -l --icons=auto --group-directories-first --git "${@:-.}"; }
la() { eza -la --icons=auto --group-directories-first --git "${@:-.}"; }
lt() { eza --tree --icons=auto --level=2 "${@:-.}"; }
