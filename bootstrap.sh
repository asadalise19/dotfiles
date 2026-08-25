#!/usr/bin/env bash
# CachyOS dotfiles bootstrap — one command to restore everything.
# Usage: ./bootstrap.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/backup-$(date +%Y%m%d-%H%M%S)"

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m ->\033[0m %s\n' "$*"; }

SUDO=""
[[ ${EUID:-$(id -u)} -ne 0 ]] && SUDO="sudo"

# --- 1. Packages -------------------------------------------------------------
if [[ -f "$DOTFILES_DIR/packages.txt" ]]; then
    log "Checking packages ($(wc -l < "$DOTFILES_DIR/packages.txt") listed)"
    declare -A in_repo=()
    while read -r repo pkg _; do
        [[ -n "$pkg" ]] && in_repo["$pkg"]=1
    done < <(pacman -Sl)
    available=()
    missing=()
    while read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if [[ -n "${in_repo[$pkg]:-}" ]]; then
            available+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done < "$DOTFILES_DIR/packages.txt"

    if ((${#available[@]})); then
        log "Installing ${#available[@]} pacman packages"
        $SUDO pacman -S --needed --noconfirm - <<< "$(printf '%s\n' "${available[@]}")"
    fi
    if ((${#missing[@]})); then
        warn "not found in repos (${#missing[@]}): ${missing[*]}"
    fi
fi

if [[ -f "$DOTFILES_DIR/aur-packages.txt" ]] && command -v yay &>/dev/null; then
    log "Installing AUR packages ($(wc -l < "$DOTFILES_DIR/aur-packages.txt") pkgs)"
    yay -S --needed --noconfirm - < "$DOTFILES_DIR/aur-packages.txt"
elif [[ -f "$DOTFILES_DIR/aur-packages.txt" ]]; then
    warn "yay not found — install it first: sudo pacman -S yay"
fi

# --- 2. Configs --------------------------------------------------------------
link() {
    local src="$DOTFILES_DIR/config/$1"
    local dest="$HOME/.config/$1"

    [[ -e "$src" ]] || { warn "missing: $1"; return; }

    if [[ -e "$dest" && ! -L "$dest" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
        warn "backed up existing $1 -> $BACKUP_DIR/"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src" "$dest"
    log "linked $1"
}

log "Linking configs"
for item in "$DOTFILES_DIR"/config/*; do
    link "$(basename "$item")"
done

# --- 3. Permissions ----------------------------------------------------------
find "$DOTFILES_DIR/config" -name '*.sh' -exec chmod +x {} \;

log "Done. Log out and back in (or reboot) to apply everything."
