# ── Keymap ────────────────────────────────────────────────────────
# Must be first — EDITOR=nvim silently enables vi mode without this
bindkey -e

# ── Smart word movement ───────────────────────────────────────────
# Default backward/forward-word treats - and / as part of a word,
# jumping the whole path/kebab-string. These widgets strip them from
# WORDCHARS locally so movement stops at each boundary.

function _backward_word_smart() {
  local WORDCHARS="${WORDCHARS//-/}"
  WORDCHARS="${WORDCHARS//\//}"
  zle backward-word
}
function _forward_word_smart() {
  local WORDCHARS="${WORDCHARS//-/}"
  WORDCHARS="${WORDCHARS//\//}"
  zle forward-word
}
function _backward_kill_word_smart() {
  local WORDCHARS="${WORDCHARS//-/}"
  WORDCHARS="${WORDCHARS//\//}"
  zle backward-kill-word
}

zle -N _backward_word_smart
zle -N _forward_word_smart
zle -N _backward_kill_word_smart

# ── Word movement bindings ────────────────────────────────────────
# Meta+b/f — Esc then b/f, or Option+b/f if macos-option-as-alt is
# set in Ghostty config (~/.config/ghostty/config: macos-option-as-alt = true)
bindkey "^[b"   _backward_word_smart
bindkey "^[f"   _forward_word_smart
bindkey "^[^?"  _backward_kill_word_smart

# Option+arrow — these send a different sequence from Option+b/f.
# Verify yours with: Ctrl+V then press the key combo.
# Common sequences — uncomment whichever matches:
# bindkey "^[[1;3D" _backward_word_smart    # Option+Left
# bindkey "^[[1;3C" _forward_word_smart     # Option+Right
# bindkey "^[[1;3A" _backward_kill_word_smart  # Option+Backspace (some terminals)
