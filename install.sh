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
  # Xcode Command Line Tools: the macOS build toolchain (clang, make,
  # headers) — the equivalent of Linux's build-essential. Homebrew needs
  # it too, so install it first.
  if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools (clang, make)..."
    xcode-select --install
    info "Finish the CLT GUI installer, then re-run this script."
  else
    skip "Xcode Command Line Tools"
  fi

  if ! check_cmd brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    skip "Homebrew"
  fi

  # fd + ripgrep: fzf-lua's file/grep pickers (<leader>ff / <leader>fg) probe for
  # these and fall back to plain `find`/`grep`, which do NOT honour .gitignore —
  # the picker then floods with node_modules, target/, build output, etc.
  # See common/.config/nvim/lua/plugins/fzf.lua.
  for pkg in zsh stow fzf fd ripgrep zoxide starship eza bat tmux neovim node \
             zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
    brew_install "$pkg"
  done
}

# ── Linux ─────────────────────────────────────────────────────────
setup_linux() {
  sudo apt-get update -qq

  # inotify-tools: gives Neovim's LSP file-watching an event-driven backend
  # (inotifywait) instead of a directory poll, so a file created by oil or an
  # agent is picked up and its imports resolve without opening it. Linux-only —
  # macOS uses fs_event natively. See lua/plugins/lsp.lua (vim.lsp.config("*")).
  for pkg in zsh stow tmux curl wget git unzip build-essential clang inotify-tools \
             ripgrep zsh-autosuggestions zsh-syntax-highlighting; do
    apt_install "$pkg"
  done

  # bat — Ubuntu ships it as batcat
  apt_install bat
  if check_cmd batcat && ! check_cmd bat; then
    info "Symlinking batcat → bat..."
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
  fi

  # fd — Ubuntu ships it as fdfind. fzf-lua probes `fdfind` before `fd` so Neovim
  # works without the symlink; the symlink is for using `fd` from the shell.
  apt_install fd-find
  if check_cmd fdfind && ! check_cmd fd; then
    info "Symlinking fdfind → fd..."
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
  fi

  if [[ ! -d "$HOME/.zsh-completions" ]]; then
    info "Cloning zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$HOME/.zsh-completions"
  else
    skip "zsh-completions"
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

  # Node LTS via NVM — NVM itself ships no node, so install one to get npm.
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  if check_cmd nvm && ! check_cmd npm; then
    info "Installing Node LTS (npm) via nvm..."
    nvm install --lts
  else
    skip "Node/npm"
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

# ── Rust toolchain (both platforms) ──────────────────────────────
# rustup installs to ~/.cargo & ~/.rustup. --no-modify-path because our
# ~/.zshenv already puts ~/.cargo/bin on PATH (single source of truth).
setup_rust() {
  if check_cmd cargo || [[ -x "$HOME/.cargo/bin/cargo" ]]; then
    skip "Rust"
    return
  fi
  info "Installing Rust (rustup)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --no-modify-path
}

# ── pnpm (both platforms) ────────────────────────────────────────
# node ships corepack, which manages pnpm without touching PATH (its shim
# lands in node's bin dir, already on PATH). Fall back to pnpm's standalone
# installer when corepack isn't available. PNPM_HOME (where `pnpm add -g`
# binaries live) is put on PATH by our zshrc, not here.
setup_pnpm() {
  if check_cmd pnpm; then
    skip "pnpm"
    return
  fi
  if check_cmd corepack; then
    info "Installing pnpm (corepack)..."
    corepack enable pnpm
    corepack prepare pnpm@latest --activate
  else
    info "Installing pnpm (standalone script)..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
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

  setup_rust
  setup_pnpm
  setup_fzf_tab
  setup_stow

  success "All done. Run: exec zsh"
}

main
