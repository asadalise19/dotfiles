#!/usr/bin/env bash
# CachyOS dotfiles bootstrap — one command to restore everything.
# Usage: ./bootstrap.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/backup-$(date +%Y%m%d-%H%M%S)"

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m ->\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m !!\033[0m %s\n' "$*"; }

SUDO=""
[[ ${EUID:-$(id -u)} -ne 0 ]] && SUDO="sudo"

# --- 0. Preflight ------------------------------------------------------------
avail_gb=$(df --output=avail -BG / | tail -1 | tr -dc '0-9')
if ((avail_gb < 10)); then
    warn "only ${avail_gb}GB free on / — full install needs ~10GB"
fi

# stale pacman lock (crashed install) — remove it; live lock — wait for it
if [[ -e /var/lib/pacman/db.lck ]]; then
    if pgrep -x pacman &>/dev/null; then
        log "another pacman is running — waiting for it to finish"
        while pgrep -x pacman &>/dev/null; do sleep 5; done
    else
        warn "removing stale pacman lock"
        $SUDO rm -f /var/lib/pacman/db.lck
    fi
fi

# refresh keyrings first — prevents most PGP/"unknown trust" errors on old ISOs
log "Refreshing keyrings"
$SUDO pacman -Sy --noconfirm --needed archlinux-keyring &>/dev/null \
    || warn "archlinux-keyring refresh failed (continuing)"
$SUDO pacman -Sy --noconfirm --needed cachyos-keyring &>/dev/null || true

# --- retry helper: mirrors flake, dbs go stale — retry with refresh ----------
retry_pacman() {
    local attempt
    for attempt in 1 2 3; do
        if "$@"; then return 0; fi
        warn "attempt $attempt/3 failed — refreshing databases, retrying"
        $SUDO pacman -Syy --noconfirm &>/dev/null || true
    done
    return 1
}

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
        if ! retry_pacman $SUDO pacman -S --needed --noconfirm - <<< "$(printf '%s\n' "${available[@]}")"; then
            err "pacman install failed after 3 attempts — fix manually, then re-run:"
            err "  $SUDO pacman -S --needed - < packages.txt"
        fi
    fi
    if ((${#missing[@]})); then
        warn "not found in repos (${#missing[@]}): ${missing[*]}"
    fi
fi

if [[ -f "$DOTFILES_DIR/aur-packages.txt" ]]; then
    # yay missing? it's in official repos — auto-install it
    if ! command -v yay &>/dev/null; then
        log "Installing yay (AUR helper)"
        retry_pacman $SUDO pacman -S --needed --noconfirm yay || warn "could not install yay"
    fi
    if command -v yay &>/dev/null; then
        log "Installing AUR packages ($(wc -l < "$DOTFILES_DIR/aur-packages.txt") pkgs)"
        if ! yay -S --needed --noconfirm - < "$DOTFILES_DIR/aur-packages.txt"; then
            warn "AUR install failed — continuing (re-run later: yay -S --needed - < aur-packages.txt)"
        fi
    else
        warn "skipping AUR packages — install yay and re-run"
    fi
fi

# --- 2. Assets (lockscreen wallpaper + avatars) ------------------------------
if [[ -d "$DOTFILES_DIR/assets" ]]; then
    log "Installing assets"
    mkdir -p "$HOME/Pictures/wallpapers"
    cp -n "$DOTFILES_DIR/assets/lockscreen.png" "$HOME/Pictures/wallpapers/" 2>/dev/null || true
    cp -n "$DOTFILES_DIR/assets/"avatar*.png "$HOME/Pictures/" 2>/dev/null || true
fi

# --- 3. Ambxst (desktop shell: bar, dock, launcher) ---------------------------
if ! command -v ambxst &>/dev/null; then
    log "Installing Ambxst"
    git clone --depth 1 https://github.com/Axenide/Ambxst.git /tmp/ambxst \
        && (cd /tmp/ambxst && ./install.sh) \
        || warn "Ambxst install failed — install manually from github.com/Axenide/Ambxst"
fi
if command -v ambxst &>/dev/null && [[ -d "$DOTFILES_DIR/config/ambxst" ]]; then
    log "Restoring Ambxst settings"
    mkdir -p "$HOME/.config/ambxst"
    cp -rn "$DOTFILES_DIR/config/ambxst/." "$HOME/.config/ambxst/"
fi

# --- 4. Custom scripts -> ~/.local/bin ----------------------------------------
if [[ -d "$DOTFILES_DIR/bin" ]]; then
    log "Linking custom scripts"
    mkdir -p "$HOME/.local/bin"
    for script in "$DOTFILES_DIR"/bin/*; do
        chmod +x "$script" 2>/dev/null
        ln -sf "$script" "$HOME/.local/bin/$(basename "$script")"
    done
fi

# --- 5. Configs --------------------------------------------------------------
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

# --- 6. Permissions ----------------------------------------------------------
find "$DOTFILES_DIR/config" -name '*.sh' -exec chmod +x {} \;

log "Done. Log out and back in (or reboot) to apply everything."
