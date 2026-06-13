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

apt_install() {
  dpkg -s "$1" &>/dev/null 2>&1 && { skip "$1"; return; }
  info "Installing $1 (apt)..."
  sudo apt-get install -y "$1"
}

# ── macOS ─────────────────────────────────────────────────────────
setup_mac() {
  if ! check_cmd brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    skip "Homebrew"
  fi

  for pkg in zsh stow fzf zoxide starship eza bat tmux neovim \
             zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
    brew_install "$pkg"
  done
}

# ── Linux ─────────────────────────────────────────────────────────
setup_linux() {
  sudo apt-get update -qq

  for pkg in zsh stow tmux curl wget git \
             zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
    apt_install "$pkg"
  done

  # bat — Ubuntu ships it as batcat
  apt_install bat
  if check_cmd batcat && ! check_cmd bat; then
    info "Symlinking batcat → bat..."
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
  fi

  # eza — not in standard apt, needs its own repo
  if ! check_cmd eza; then
    info "Installing eza..."
    sudo apt-get install -y gpg
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
      | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
      | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -qq && sudo apt-get install -y eza
  else
    skip "eza"
  fi

  # fzf — apt version too old for `fzf --zsh`, install from git
  if ! check_cmd fzf; then
    info "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --bin
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
  else
    skip "fzf"
  fi

  # zoxide — not in apt
  if ! check_cmd zoxide; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  else
    skip "zoxide"
  fi

  # starship — not in apt
  if ! check_cmd starship; then
    info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
  else
    skip "starship"
  fi

  # neovim — apt version outdated, use pre-built binary
  if ! check_cmd nvim; then
    info "Installing neovim..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm nvim-linux-x86_64.tar.gz
  else
    skip "neovim"
  fi

  # NVM — not in apt, use official install script
  if [[ ! -d "$HOME/.nvm" ]]; then
    info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  else
    skip "NVM"
  fi

  # conda — not in apt
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

# ── fzf-tab (both platforms) ─────────────────────────────────────
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
