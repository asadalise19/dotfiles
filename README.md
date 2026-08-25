<div align="center">

# asad's dotfiles

**CachyOS · Hyprland · Ambxst** — my full Linux rice, restorable with one command.

<img src="https://github.com/asadalise19/dotfiles/raw/main/assets/screenshot.png" alt="Desktop"/>

*Hyprland + Ambxst bar/dock + ghostty + opencode*

![Lockscreen](assets/lockscreen.png)

*hyprlock — macOS-style glass lockscreen*

![CachyOS](https://img.shields.io/badge/CachyOS-rolling-3893d1?logo=linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-wayland-00a1a8)
![Shell](https://img.shields.io/badge/shell-fish-green)

</div>

## One-command restore

On a fresh CachyOS (install with **no desktop environment**):

```bash
sudo pacman -S --needed git && git clone https://github.com/asadalise19/dotfiles.git && cd dotfiles && ./bootstrap.sh
```

Then reboot. That's it — login via SDDM into Hyprland.

## What it installs

| Component | What |
|---|---|
| 237 pacman + 10 AUR packages | Full package list from `packages.txt` / `aur-packages.txt` |
| [Ambxst](https://github.com/Axenide/Ambxst) | Desktop shell — bar, dock, notch, launcher, overview |
| [vicinae](https://github.com/vicinaehq/vicinae) | Raycast-style launcher (`SUPER+Space`), clipboard history (`SUPER+V`) |
| hyprlock | Lockscreen with wallpaper + avatar |
| fish · ghostty · kitty | Shell + terminals (ghostty themed) |
| cava | Audio visualizer shaders/themes |
| Custom scripts | numlock enforcement, ydotoold wrapper → `~/.local/bin` |

## Self-healing installer

`bootstrap.sh` handles failures automatically:

| Error | Auto-fix |
|---|---|
| PGP / "unknown trust" (old ISO keys) | Refreshes `archlinux-keyring` + `cachyos-keyring` first |
| Stale pacman lock | Detects + removes; waits if pacman is live |
| Mirror / network failure | Retries 3× with `pacman -Syy` between attempts |
| `yay` missing | Auto-installs from official repos |
| AUR build fails | Warns, continues — configs still linked |
| Pacman fails completely | Prints manual-fix command, still links configs |
| Existing configs | Backed up to `~/.config/backup-<date>/` before symlinking |

## Structure

```
dotfiles/
├── bootstrap.sh        the installer (idempotent — safe to re-run)
├── packages.txt        236 explicit pacman packages
├── aur-packages.txt    10 AUR packages
├── assets/             README images + lockscreen wallpaper + avatars
├── bin/                custom scripts → ~/.local/bin
└── config/             symlinked into ~/.config/
    ├── ambxst/         desktop shell settings (bar, dock, theme, binds)
    ├── hypr/           hyprland + hyprlock + scripts
    ├── eww/            widgets
    ├── ghostty/         terminal config (theme, font)
    ├── fish/           shell config
    └── cava/           visualizer
```

## Keybinds

| Keys | Action |
|---|---|
| `SUPER + Return` | Terminal (ghostty) |
| `SUPER + Space` | vicinae launcher |
| `SUPER + V` | Clipboard history |
| `SUPER + B` | Browser |
| `SUPER + E` | Files (nautilus) |
| `SUPER + Q` | Close window |
| `SUPER + M` | Power menu |
| `ALT + Tab` | Cycle windows |

## Maintenance

Configs are **live symlinks** — edits apply instantly. When you change something worth keeping:

```bash
git add -A && git commit -m "update" && git push
```

After installing new packages:

```bash
pacman -Qqe > packages.txt && pacman -Qqem > aur-packages.txt
git add -A && git commit -m "update packages" && git push
```

---

<div align="center">

Built on [CachyOS](https://cachyos.org) · desktop shell by [Ambxst](https://github.com/Axenide/Ambxst)

</div>
