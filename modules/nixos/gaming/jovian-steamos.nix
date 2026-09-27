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
    };
}
