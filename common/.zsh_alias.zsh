# ── Aliases ──────────────────────────────────────────────────────
# Shared across macOS and Linux. Sourced from both .zshrc files.

# ── General ──────────────────────────────────────────────────────
alias ca="conda activate"
alias cda="conda deactivate"
alias py3="python3"
alias treet="tree -I 'node_modules|__pycache__|.nuxt|dist|.next|target|icons'"

# ── autossh (persistent SSH, auto-reconnect) ─────────────────────
# Wraps autossh with keepalives, and forwards Discord's IPC socket so
# cord.nvim running on the remote drives Rich Presence on THIS Mac's
# Discord client. autossh runs plain ssh underneath, so — unlike mosh —
# it can carry a -R Unix-socket forward and re-establish it on reconnect.
#
# The local socket ($TMPDIR/discord-ipc-N on macOS) is auto-detected and
# the -R flag is added ONLY when Discord is running, so a closed Discord
# never blocks the login. It lands on the server at
# /run/user/<uid>/discord-ipc-0, which cord finds via XDG_RUNTIME_DIR.
# Override the remote uid per-host with DISCORD_REMOTE_UID=... (default
# 1000). Requires `StreamLocalBindUnlink yes` in the server's
# sshd_config so a reconnect can replace the stale socket.
unalias autossh_connect 2>/dev/null
autossh_connect() {
  local fwd=() sock
  for sock in ${TMPDIR:-/tmp}/discord-ipc-*(Nom) /tmp/discord-ipc-*(Nom); do
    [[ -S $sock ]] || continue
    fwd=(-R "/run/user/${DISCORD_REMOTE_UID:-1000}/discord-ipc-0:$sock")
    break
  done
  autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' "${fwd[@]}" "$@"
}

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
