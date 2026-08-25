# dotfiles

CachyOS (Arch) setup — Hyprland + eww + fish. Restorable with one command.

## Fresh install

```bash
git clone https://github.com/asadalise19/dotfiles.git
cd dotfiles
./bootstrap.sh
```

Installs all packages (pacman + AUR via yay), backs up any existing configs to `~/.config/backup-*`, and symlinks everything into `~/.config/`.

## Structure

```
config/            symlinked into ~/.config/
├── hypr/          Hyprland + hyprlock + scripts
├── eww/           widgets
├── fish/          shell config
└── cava/          audio visualizer
packages.txt       explicit pacman packages
aur-packages.txt   AUR packages
bootstrap.sh       installer
```

## After changing configs

Configs are live symlinks — edits apply immediately. When you change something worth keeping:

```bash
git add -A && git commit -m "update" && git push
```

## Update package lists

```bash
pacman -Qqe > packages.txt
pacman -Qqem > aur-packages.txt
```
