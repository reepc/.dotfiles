#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── OS Detection ──────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="mac" ;;
  Linux)  PLATFORM="linux" ;;
  *)      echo "Unsupported OS: $OS"; exit 1 ;;
esac

# ── Helpers ───────────────────────────────────────────────────────
info()    { echo "[+] $*"; }
skip()    { echo "[=] $* — already installed"; }
success() { echo "[✓] $*"; }

check_cmd() { command -v "$1" &>/dev/null; }

brew_install() {
  brew list "$1" &>/dev/null 2>&1 && { skip "$1"; return; }
  info "Installing $1 (brew)..."
  brew install "$1"
}

# ── Brew packages (identical on both platforms) ───────────────────
setup_brew_packages() {
  for pkg in zsh stow fzf zoxide starship eza bat tmux neovim \
             zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
    brew_install "$pkg"
  done
}

# ── macOS ─────────────────────────────────────────────────────────
setup_mac() {
  if ! check_cmd brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    skip "Homebrew"
  fi

  setup_brew_packages
}

# ── Linux ─────────────────────────────────────────────────────────
setup_linux() {
  # Minimal apt prerequisites for Homebrew to build from source
  info "Installing apt prerequisites..."
  sudo apt-get update -qq
  sudo apt-get install -y build-essential curl file git

  # Homebrew (Linuxbrew)
  if ! check_cmd brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    skip "Homebrew"
  fi

  setup_brew_packages

  # NVM — not in Homebrew, use official install script
  if [[ ! -d "$HOME/.nvm" ]]; then
    info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  else
    skip "NVM"
  fi

  # Conda — not in Homebrew
  if ! check_cmd conda; then
    info "Installing Miniconda..."
    mkdir -p "$HOME/miniconda3"
    curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
      -o "$HOME/miniconda3/miniconda.sh"
    bash "$HOME/miniconda3/miniconda.sh" -b -u -p "$HOME/miniconda3"
    rm "$HOME/miniconda3/miniconda.sh"
  else
    skip "conda"
  fi

  # Set zsh as default shell
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
  fi
}

# ── fzf-tab ───────────────────────────────────────────────────────
setup_fzf_tab() {
  if [[ ! -d "$HOME/.fzf-tab" ]]; then
    info "Cloning fzf-tab..."
    git clone https://github.com/Aloxaf/fzf-tab "$HOME/.fzf-tab"
  else
    skip "fzf-tab"
  fi
}

# ── Stow ──────────────────────────────────────────────────────────
setup_stow() {
  info "Stowing dotfiles..."
  cd "$DOTFILES_DIR"

  stow --target="$HOME" --restow common

  if [[ "$PLATFORM" == "mac" ]]; then
    stow --target="$HOME" --restow zsh-mac
  else
    stow --target="$HOME" --restow zsh-linux
  fi

  success "Dotfiles stowed."
}

# ── Main ──────────────────────────────────────────────────────────
main() {
  info "Platform: $PLATFORM"

  [[ "$PLATFORM" == "mac" ]]   && setup_mac
  [[ "$PLATFORM" == "linux" ]] && setup_linux

  setup_fzf_tab
  setup_stow

  success "All done. Run: exec zsh"
}

main
