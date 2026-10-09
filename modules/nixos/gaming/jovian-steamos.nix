# Full Jovian steam stack (needed for the Quick Access "Performance" panel),
# not just decky-loader. No autoStart: Steam Big Picture (gamescope-wayland)
# is picked as a session from noctalia-greeter instead of SDDM auto-login.
# "Switch to Desktop" in Gaming Mode won't reach umbriel without SDDM.
{ config, inputs, ... }:
let
  inherit (config.flake) meta;
in
{
  flake.modules.nixos.gaming =
    { lib, ... }:
    {
      imports = [
        inputs.jovian.nixosModules.default
      ];

      # jovian.steam hard-references Deck-specific packages (steamos-manager,
      # gamescope-session, inputplumber, ...) that only exist through this
      # overlay.
      nixpkgs.overlays = [
        inputs.jovian.overlays.default
        # Jovian's mangohud override re-appends a patch nixpkgs' own mangohud
        # derivation already carries, so the build tries to apply it twice
        # and fails ("Reversed (or previously applied) patch detected").
        # gamescope-session (and thus jovian.steam) needs a working mangohud,
        # so dedupe the patch list rather than dropping the override.
        (final: prev: {
          mangohud = prev.mangohud.overrideAttrs (old: {
            patches = lib.unique old.patches;
          });
        })
      ];

      jovian.steam = {
        enable = true;
        user = meta.owner.username;
      };

      # jovian.steam turns on useSteamOSConfig, i.e. Deck-tuned system
      # defaults. Opt out of the ones that don't fit these machines:
      jovian.steamos = {
        # Deck boot flags: amd_iommu=off (fights the Z13's iommu=pt), audit=0,
        # Deck GPU lockup timeouts, and a second amdgpu.dcdebugmask.
        enableDefaultCmdlineConfig = false;
        # SD card automount udev rules; udiskie already handles removable media.
        enableAutoMountUdevRules = false;
      };

      # Pulled in by jovian.steam but not started; kept off since scx_lavd
      # misbehaved here before (see ./kernel.nix).
      services.scx.enable = false;
      # Screen reader for the Deck UI's accessibility settings; unused.
      services.orca.enable = false;
    };
}
