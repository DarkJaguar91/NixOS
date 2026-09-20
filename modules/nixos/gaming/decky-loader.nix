{ config, inputs, ... }:
let
  inherit (config.flake) meta;
in
{
  flake.modules.nixos.gaming =
    { ... }:
    {
      imports = [
        inputs.jovian.nixosModules.default
      ];

      # jovian.overlays.default (providing pkgs.decky-loader) is applied in
      # ./jovian-steamos.nix, which jovian.steam also needs.
      jovian.decky-loader.enable = true;

      # Steam's CEF overlay needs remote debugging enabled or Decky can't
      # attach to inject its UI: https://github.com/Jovian-Experiments/Jovian-NixOS/issues/460
      # Targets the real Steam data dir directly: systemd-tmpfiles refuses to
      # traverse the ~/.steam/steam symlink ("unsafe path transition").
      systemd.tmpfiles.rules = [
        "f /home/${meta.owner.username}/.local/share/Steam/.cef-enable-remote-debugging 0644 ${meta.owner.username} users -"
      ];
    };
}
