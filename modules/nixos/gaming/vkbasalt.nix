# vkBasalt post-processing layer. Opt in per game with ENABLE_VKBASALT=1,
# plus VKBASALT_CONFIG_FILE=~/.config/vkBasalt/games/<game>.conf for a
# per-game config (see dotfiles/vkbasalt/).
#
# ReShade shaders are flattened into one directory, linked at
# ~/.local/share/reshade so the repo-managed configs can reference a stable
# path. It has to live under $HOME: Steam's pressure-vessel container sees
# the home dir and /nix/store, but not the host's /etc.
#   ~/.local/share/reshade/Shaders   SweetFX *.fx + ReShade *.fxh headers
#   ~/.local/share/reshade/Textures
{ config, inputs, ... }:
let
  inherit (config.flake) meta;
in
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    let
      reshade-shaders = pkgs.runCommand "reshade-shaders" { } ''
        mkdir -p $out/Shaders $out/Textures
        cp -r ${inputs.reshade-shaders}/Shaders/. $out/Shaders/
        cp -r ${inputs.reshade-shaders}/Textures/. $out/Textures/
        cp -r ${inputs.sweetfx}/Shaders/SweetFX/. $out/Shaders/
      '';
    in
    {
      # ships both 64- and 32-bit layer manifests
      environment.systemPackages = [ pkgs.vkbasalt ];

      # Proton-CachyOS adds its own bundled vkBasalt layer when
      # ENABLE_VKBASALT=1. Its manifest loads the bare "libvkbasalt.so",
      # which resolves (same SONAME) to the already-loaded Nix copy, so the
      # one library ends up in the layer chain twice and deadlocks on its
      # own global lock in vkCreateInstance: Steam says "running" but no
      # window ever appears. Keep only the Nix layer.
      environment.sessionVariables.VK_LOADER_LAYERS_DISABLE = "VK_LAYER_VKBASALT_post_processing";

      systemd.tmpfiles.rules = [
        "L+ /home/${meta.owner.username}/.local/share/reshade - - - - ${reshade-shaders}"
      ];

      dots.directories.".config/vkBasalt" = "vkbasalt";
    };
}
