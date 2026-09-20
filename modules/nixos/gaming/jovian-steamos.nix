# Boots straight into Steam Big Picture (gamescope-wayland) via SDDM
# auto-login, SteamOS-style. "Switch to Desktop" in Gaming Mode relogs into
# umbriel via steamos-manager. This is the full Jovian steam stack (needed
# for the Quick Access "Performance" panel and the desktop-switch button),
# not just decky-loader.
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
        autoStart = true;
        desktopSession = "umbriel";
      };

      # autoStart drives login/relogin through SDDM itself (steamosctl sets
      # the next session, then triggers a relogin). Can't coexist with
      # noctalia-greeter/greetd also trying to own the seat.
      services.displayManager.noctalia-greeter.enable = lib.mkForce false;
    };
}
