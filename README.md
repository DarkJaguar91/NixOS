# NixOS Configuration

Dendritic-style flake for three hosts, no home-manager.

| Host | Machine | Role |
|---|---|---|
| `DarkJaguar` | Ryzen 9 9900X + RX 9070 (RDNA4) | Gaming desktop |
| `AsusZ13` | ROG Flow Z13 2025 (Strix Halo) | Laptop/tablet |
| `DJServer` | Intel + RTX 2000 Ada | Headless server |

## Layout

```
flake.nix                  flake-parts + import-tree; small, never grows
dotfiles/                  live-editable configs, symlinked into ~ (see below)
modules/
  flake/                   glue: meta (owner facts), hosts -> nixosConfigurations,
                           formatter (nix fmt), per-host eval checks
  hosts/                   one file per machine: hardware facts + aggregate imports
  nixos/
    base/                  every host: nix/nh, boot, network, user, fish+tide,
                           git, neovim (LazyVim), claude-code + opencode,
                           dots helper
    desktop/               umbriel (flake), noctalia + noctalia-greeter
                           (flakes), pipewire, bluetooth, USB automount, fonts,
                           kitty, firefox/discord/spotify, network timezone
    gaming/                latest kernel, Steam stack, Jovian SteamOS session
                           (boots into Gaming Mode) + Decky Loader, xpadneo
    hardware/              amd, amdgpu-gamemode-perf, nvidia, backlight, ASUS
                           Z13 quirks (copilot key, touchpad kernel patch)
    server/                DJServer: servarr stack, recyclarr, seerr, jellyfin +
                           plex, immich, caddy, homepage, auto-upgrade
    printing/              3D printing: FreeCAD, OpenSCAD, OrcaSlicer
    laptop.nix             auto-cpufreq, fwupd
    netbird.nix            mesh VPN client (laptop + server)
```

Every file under `modules/` is a flake-parts module. Feature files contribute
to named aggregates (`flake.modules.nixos.base`, `.desktop`, `.gaming`, ...);
host files compose aggregates and become `nixosConfigurations` automatically.
Adding a feature = adding one file. Nothing central to edit.

## Dotfiles

`dotfiles/` is symlinked into `$HOME` by the `dots` helper
(`modules/nixos/base/dots.nix`, systemd-tmpfiles under the hood). Links point
at this repo checkout — **not** the nix store — so edits apply live without a
rebuild, while staying version-controlled.

Deliberately unmanaged runtime state:

- `~/.local/state/noctalia` — caches and notification history (only
  `settings.toml` is linked into the repo)
- `~/.config/fish/fish_variables` — tide's style (bootstrap in config.fish)
- noctalia/matugen theme outputs (kitty theme, `nvim/lua/matugen.lua`) —
  regenerated on wallpaper change, gitignored

## Usage

```sh
nh os switch                    # rebuild current host (flake path is baked in)
nh os switch -u                 # rebuild + update flake inputs
sudo nixos-rebuild switch --flake ~/.config/NixOS#DarkJaguar   # explicit host
nix flake check                 # evaluate all three hosts without building
nix fmt                         # format the tree (nixfmt-rfc-style)
```

DJServer additionally runs `system.autoUpgrade` daily against the pushed
`dendritic` branch (no auto-reboot) — push from any machine and it picks up
the change overnight. Desktops are rebuilt by hand.

## Fresh install / reinstall

Disks are partitioned by hand; each host file carries its own `fileSystems`
by UUID. Boot a NixOS ISO, partition/format/mount to `/mnt`, then:

```sh
export NIX_CONFIG="experimental-features = nix-command flakes"

# print the new disk UUIDs + kernel modules; copy them into
# modules/hosts/<host>.nix and push before installing
nixos-generate-config --root /mnt --show-hardware-config

sudo nixos-install --flake github:DarkJaguar91/NixOS/dendritic#<host>
```

Then: set a password for brandon (`nixos-enter --root /mnt -c 'passwd
brandon'` before rebooting), reboot, clone this repo to `~/.config/NixOS`,
re-enroll netbird.

First boot on a fresh setup: tide auto-configures on the first shell, LazyVim
installs plugins on the first `nvim` launch.

## Migration status (2026-07)

The previous config lives at `~/NixOS` and stays untouched. Everything in
daily use has been ported, including the full DJServer stack and netbird.
Intentionally not ported (grab from the old repo if wanted later):

- vkBasalt + ReShade shader setup, mangowc compositor
- media extras (jellyfin-desktop, yacreader)
- kmscon console
- `claude-local` fish function (pointed at DJServer's ollama, since removed)
